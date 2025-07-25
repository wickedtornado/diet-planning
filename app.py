from flask import Flask, request, jsonify, send_from_directory, make_response
from groq import Groq
import json
import hashlib
from datetime import datetime
from prompts import build_intelligent_diet_prompt, validate_response_format, flag_high_risk_case
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.pdfgen import canvas
from reportlab.platypus.tableofcontents import TableOfContents
import io
import re
import os

# Import our nutrition database integration
from nutrition_db import NutritionDatabaseIntegration

app = Flask(__name__)

# Production configuration
app.config['ENV'] = os.getenv('FLASK_ENV', 'production')
app.config['DEBUG'] = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
app.config['TESTING'] = False

client = Groq(
    api_key="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"
)

# Get API keys
USDA_API_KEY = "bPS4XM0z4cbbpuA7lK5qChEpnfhMGXTfYvfnctOQ"
if not USDA_API_KEY:
    print("⚠️ WARNING: USDA_API_KEY not available")

class IntelligentDietPlanner:
    def __init__(self):
        self.client = client
        self.response_cache = {}  # Simple in-memory cache

        # Initialize nutrition database integration
        if USDA_API_KEY:
            try:
                self.nutrition_db = NutritionDatabaseIntegration(USDA_API_KEY)
                print("✅ Nutrition databases initialized successfully")

                # Test API connections
                api_status = self.nutrition_db.test_api_connections()
                print(f"USDA API: {api_status['usda']['status']}")
                print(f"RxNorm API: {api_status['rxnorm']['status']}")

            except Exception as e:
                print(f"⚠️ Warning: Nutrition database initialization failed: {e}")
                self.nutrition_db = None
        else:
            print("⚠️ Warning: USDA API key not provided, running without nutrition database")
            self.nutrition_db = None

    def calculate_bmr(self, age, weight, height, gender):
        """Calculate Basal Metabolic Rate using Harris-Benedict equation"""
        age = float(age)
        weight = float(weight)
        height = float(height)

        if gender.lower() == 'male':
            bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        else:
            bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
        return bmr

    def calculate_bmi(self, weight, height):
        """Calculate Body Mass Index"""
        weight = float(weight)
        height = float(height)
        height_m = height / 100
        bmi = weight / (height_m * height_m)
        return round(bmi, 1)

    def get_bmi_category_and_advice(self, bmi):
        """Get BMI category and dietary recommendations"""
        if bmi < 18.5:
            return {
                'category': 'Underweight',
                'advice': 'Focus on healthy weight gain with nutrient-dense foods',
                'calorie_adjustment': 1.15,
                'priority': 'Weight gain through healthy foods'
            }
        elif 18.5 <= bmi < 25:
            return {
                'category': 'Normal weight',
                'advice': 'Maintain current weight with balanced nutrition',
                'calorie_adjustment': 1.0,
                'priority': 'Maintenance and optimal nutrition'
            }
        elif 25 <= bmi < 30:
            return {
                'category': 'Overweight',
                'advice': 'Gradual weight loss through moderate calorie deficit',
                'calorie_adjustment': 0.85,
                'priority': 'Sustainable weight loss'
            }
        else:
            return {
                'category': 'Obese',
                'advice': 'Significant weight loss recommended',
                'calorie_adjustment': 0.75,
                'priority': 'Medically supervised weight loss'
            }

    def calculate_daily_calories(self, bmr, activity_level, goal, bmi_adjustment=1.0):
        """Calculate daily calorie needs"""
        activity_multipliers = {
            'sedentary': 1.2,
            'light': 1.375,
            'moderate': 1.55,
            'active': 1.725,
            'very_active': 1.9
        }

        calories = bmr * activity_multipliers.get(activity_level, 1.55)
        calories *= bmi_adjustment

        if goal == 'lose_fat':
            calories *= 0.9
        elif goal == 'gain_muscle':
            calories *= 1.1

        return int(calories)

    def get_cache_key(self, user_data):
        """Generate cache key for similar requests"""
        # Only cache based on core health data, not personal identifiers
        cache_data = {
            'height': user_data.get('height'),
            'weight': user_data.get('weight'),
            'age': user_data.get('age'),
            'gender': user_data.get('gender'),
            'diagnosis': user_data.get('diagnosis', '').lower().strip(),
            'preexisting': user_data.get('preexisting', '').lower().strip(),
            'medicines': user_data.get('medicines', '').lower().strip(),
            'allergies': user_data.get('allergies', '').lower().strip(),
            'diet-type': user_data.get('diet-type'),
            'diet-goal': user_data.get('diet-goal'),
            'exercise': user_data.get('exercise')
        }
        return hashlib.md5(json.dumps(cache_data, sort_keys=True).encode()).hexdigest()

    def generate_intelligent_diet_plan(self, user_data):
        """Generate diet plan using intelligent LLM approach"""
        try:
            # Map and validate user data
            mapped_data = self.map_frontend_data(user_data)

            # Basic calculations
            height = float(mapped_data.get('height', 170))
            weight = float(mapped_data.get('weight', 70))
            age = int(mapped_data.get('age', 30))
            gender = mapped_data.get('gender', 'male')

            # Calculate BMI and BMR
            bmi = self.calculate_bmi(weight, height)
            bmi_info = self.get_bmi_category_and_advice(bmi)
            bmr = self.calculate_bmr(age, weight, height, gender)

            # Calculate daily calories
            daily_calories = self.calculate_daily_calories(
                bmr,
                mapped_data.get('exercise', 'moderate'),
                mapped_data.get('diet-goal', 'balanced'),
                bmi_info['calorie_adjustment']
            )

            # Update mapped data with calculated values
            mapped_data.update({
                'age': age,
                'gender': gender,
                'weight': weight,
                'height': height,
                'bmi': bmi,
                'bmi_category': bmi_info['category']
            })

            # Check for high-risk cases using imported function
            is_high_risk, risk_condition = flag_high_risk_case(mapped_data)

            # Check cache for similar requests (skip cache for high-risk cases)
            cache_key = self.get_cache_key(mapped_data)
            if cache_key in self.response_cache and not is_high_risk:
                cached_response = self.response_cache[cache_key]
                print(f"Using cached response for similar case")
                return {
                    **cached_response,
                    'cached': True,
                    'cache_key': cache_key[:8]
                }

            # Build intelligent prompt using imported function
            prompt = build_intelligent_diet_prompt(mapped_data, daily_calories)

            # Enhance prompt with nutrition database data if available
            if self.nutrition_db:
                try:
                    enhanced_prompt = self.nutrition_db.enhance_llm_prompt_with_nutrition_data(
                        prompt, mapped_data
                    )
                    print("✅ Prompt enhanced with nutrition database data")
                except Exception as e:
                    print(f"⚠️ Warning: Could not enhance prompt with nutrition data: {e}")
                    enhanced_prompt = prompt
            else:
                enhanced_prompt = prompt

            # Call LLM with optimal settings for consistency
            response = self.client.chat.completions.create(
                messages=[{
                    "role": "system",
                    "content": "You are a senior clinical nutritionist with access to USDA FoodData Central and RxNorm databases. Use this data to provide exact nutrition information and verified drug interactions. Always follow the exact format provided."
                }, {
                    "role": "user",
                    "content": enhanced_prompt
                }],
                model="llama3-70b-8192",
                temperature=0.1,  # Very low for consistency
                max_tokens=2500,  # Increased for complete responses
                top_p=0.9,
                frequency_penalty=0,
                presence_penalty=0
            )

            diet_plan_content = response.choices[0].message.content

            # Validate response format using imported function
            validation = validate_response_format(diet_plan_content)

            result = {
                'success': True,
                'bmr': int(bmr),
                'bmi': bmi,
                'bmi_category': bmi_info['category'],
                'bmi_advice': bmi_info['advice'],
                'daily_calories': daily_calories,
                'calorie_adjustment': f"{int((bmi_info['calorie_adjustment'] - 1) * 100):+d}% based on BMI",
                'diet_plan': diet_plan_content,
                'high_risk': is_high_risk,
                'risk_condition': risk_condition if is_high_risk else None,
                'validation': validation,
                'generated_at': datetime.now().isoformat(),
                'approach': 'intelligent_llm_with_nutrition_db',
                'nutrition_db_used': self.nutrition_db is not None
            }

            # Cache successful responses (except high-risk cases)
            if not is_high_risk and validation['valid']:
                self.response_cache[cache_key] = {
                    'success': True,
                    'bmr': int(bmr),
                    'bmi': bmi,
                    'bmi_category': bmi_info['category'],
                    'bmi_advice': bmi_info['advice'],
                    'daily_calories': daily_calories,
                    'calorie_adjustment': f"{int((bmi_info['calorie_adjustment'] - 1) * 100):+d}% based on BMI",
                    'diet_plan': diet_plan_content,
                    'approach': 'intelligent_llm_with_nutrition_db'
                }

            # Add warnings for high-risk cases
            if is_high_risk:
                result[
                    'medical_warning'] = f"High-risk condition detected: {risk_condition}. Please consult healthcare provider before implementing this plan."

            # Add warnings for validation issues
            if not validation['valid']:
                result[
                    'format_warning'] = f"Response may be incomplete. Missing sections: {', '.join(validation['missing_sections'])}"

            return result

        except Exception as e:
            print(f"Error in generate_intelligent_diet_plan: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'error_type': 'generation_error'
            }

    def preprocess_medical_text(self, text):
        """Preprocess medical text to handle common typos"""
        if not text or not isinstance(text, str):
            return text

        medical_corrections = {
            'diabetis': 'diabetes',
            'diabetic': 'diabetes',
            'hypertenion': 'hypertension',
            'hypertention': 'hypertension',
            'high bp': 'hypertension',
            'hart disease': 'heart disease',
            'thyroids': 'thyroid',
            'metformine': 'metformin',
            'lisiniprol': 'lisinopril',
            'lactos intolerant': 'lactose intolerant',
            'glutten': 'gluten',
            'shelfish': 'shellfish'
        }

        corrected_text = text.lower()
        for typo, correction in medical_corrections.items():
            corrected_text = corrected_text.replace(typo.lower(), correction.lower())

        if text and text[0].isupper():
            corrected_text = corrected_text.capitalize()

        return corrected_text

    def map_frontend_data(self, frontend_data):
        """Map frontend form data to expected format"""
        return {
            'height': frontend_data.get('height', '170'),
            'weight': frontend_data.get('weight', '70'),
            'age': frontend_data.get('age', '30'),
            'gender': frontend_data.get('gender', 'male'),
            'budget': frontend_data.get('budget', '200'),

            'diagnosis': self.preprocess_medical_text(frontend_data.get('diagnosis', '')),
            'preexisting': self.preprocess_medical_text(frontend_data.get('preexisting', '')),
            'medicines': self.preprocess_medical_text(frontend_data.get('medicines', '')),
            'allergies': self.preprocess_medical_text(frontend_data.get('allergies', '')),
            'additional-health': self.preprocess_medical_text(frontend_data.get('additional-health', '')),

            'diet-type': frontend_data.get('diet-type', 'vegetarian'),
            'diet-goal': frontend_data.get('diet-goal', 'balanced'),
            'exercise': frontend_data.get('exercise', 'moderate'),
            'food-preference': frontend_data.get('food-preference', 'home_based'),

            'cuisines': frontend_data.get('cuisines', []),

            'fasting': frontend_data.get('fasting', 'none'),
            'fasting-details': frontend_data.get('fasting-details', '')
        }

    def extract_section_text(self, text, start_marker, end_marker):
        """Extract section text for PDF generation"""
        if not text:
            return "Information not available"

        start_index = text.find(start_marker)
        if start_index == -1:
            return "Section not found"

        start_content = start_index + len(start_marker)
        end_index = text.find(end_marker, start_content)

        if end_index == -1:
            return text[start_content:].strip()
        else:
            return text[start_content:end_index].strip()

    def clean_text_for_pdf(self, text):
        """Clean text for PDF generation"""
        if not text:
            return ""

        text = re.sub(r'\n\s*\n', '\n\n', text)
        text = re.sub(r'[ \t]+', ' ', text)

        emoji_pattern = re.compile("["
                                   u"\U0001F600-\U0001F64F"
                                   u"\U0001F300-\U0001F5FF"
                                   u"\U0001F680-\U0001F6FF"
                                   u"\U0001F1E0-\U0001F1FF"
                                   u"\U00002702-\U000027B0"
                                   u"\U000024C2-\U0001F251"
                                   "]+", flags=re.UNICODE)
        text = emoji_pattern.sub('', text)

        text = re.sub(r'[•·‣⁃]', '-', text)

        return text.strip()

    def generate_pdf_diet_plan(self, user_data, result):
        """Generate PDF diet plan"""
        try:
            buffer = io.BytesIO()

            doc = SimpleDocTemplate(
                buffer,
                pagesize=A4,
                rightMargin=72,
                leftMargin=72,
                topMargin=72,
                bottomMargin=18
            )

            styles = getSampleStyleSheet()

            title_style = ParagraphStyle(
                'CustomTitle',
                parent=styles['Heading1'],
                fontSize=24,
                spaceAfter=30,
                alignment=TA_CENTER,
                textColor=HexColor('#2563eb')
            )

            header_style = ParagraphStyle(
                'CustomHeader',
                parent=styles['Heading2'],
                fontSize=16,
                spaceAfter=12,
                spaceBefore=20,
                textColor=HexColor('#1e40af')
            )

            normal_style = ParagraphStyle(
                'CustomNormal',
                parent=styles['Normal'],
                fontSize=11,
                spaceAfter=6,
                leading=14
            )

            story = []

            story.append(Paragraph("🌟 Halo Health Eats", title_style))
            story.append(Paragraph("Personalized AI Diet Plan", styles['Heading2']))
            story.append(Spacer(1, 20))

            health_data = [
                ['Health Summary', ''],
                ['BMR (calories/day)', str(result.get('bmr', 'N/A'))],
                ['BMI', f"{result.get('bmi', 'N/A')} ({result.get('bmi_category', 'N/A')})"],
                ['Target Calories/day', str(result.get('daily_calories', 'N/A'))],
                ['Generated On', datetime.now().strftime('%B %d, %Y at %I:%M %p')]
            ]

            health_table = Table(health_data, colWidths=[3 * inch, 3 * inch])
            health_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), HexColor('#3b82f6')),
                ('TEXTCOLOR', (0, 0), (-1, 0), HexColor('#ffffff')),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 12),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), HexColor('#f8fafc')),
                ('GRID', (0, 0), (-1, -1), 1, HexColor('#e2e8f0'))
            ]))

            story.append(health_table)
            story.append(Spacer(1, 20))

            diet_plan_text = result.get('diet_plan', '')

            sections = [
                ('Clinical Assessment', '🔬 CLINICAL ASSESSMENT:', '📊 PERSONALIZED MACRONUTRIENT PLAN:'),
                ('Macronutrient Plan', '📊 PERSONALIZED MACRONUTRIENT PLAN:', '🍽️ DAILY MEAL PLAN'),
                ('Daily Meal Plan', '🍽️ DAILY MEAL PLAN', '🚫 FOODS TO STRICTLY AVOID:'),
                ('Foods to Avoid', '🚫 FOODS TO STRICTLY AVOID:', '✅ THERAPEUTIC FOODS TO EMPHASIZE:'),
                ('Therapeutic Foods', '✅ THERAPEUTIC FOODS TO EMPHASIZE:', '⏰ MEAL TIMING STRATEGY:')
            ]

            for title, start, end in sections:
                section_text = self.extract_section_text(diet_plan_text, start, end)
                if section_text and section_text != "Section not found":
                    story.append(Paragraph(title, header_style))
                    story.append(Paragraph(self.clean_text_for_pdf(section_text), normal_style))
                    story.append(Spacer(1, 15))

            # Medical Disclaimers
            disclaimer_text = self.extract_section_text(
                diet_plan_text,
                '⚠️ IMPORTANT MEDICAL DISCLAIMERS:',
                '═══════════'
            )
            if disclaimer_text and disclaimer_text != "Section not found":
                story.append(Spacer(1, 20))
                story.append(Paragraph("Important Medical Disclaimers", header_style))
                story.append(Paragraph(self.clean_text_for_pdf(disclaimer_text), normal_style))

            doc.build(story)

            pdf_data = buffer.getvalue()
            buffer.close()

            return pdf_data

        except Exception as e:
            print(f"Error generating PDF: {str(e)}")
            return None


# Initialize diet planner
diet_planner = IntelligentDietPlanner()


# Routes
@app.route('/')
def index():
    return send_from_directory('.', 'index.html')


@app.route('/test.html')
def assessment():
    return send_from_directory('.', 'test.html')


@app.route('/generate_diet', methods=['POST'])
def generate_diet():
    """Main endpoint for generating diet plans"""
    try:
        user_data = request.json
        print("Received data:", {k: v for k, v in user_data.items() if k not in ['diagnosis', 'medicines']})

        result = diet_planner.generate_intelligent_diet_plan(user_data)

        print(
            f"Generated result - Success: {result.get('success', False)}, High Risk: {result.get('high_risk', False)}")

        return jsonify(result)

    except Exception as e:
        print("Error in generate_diet endpoint:", str(e))
        return jsonify({
            'success': False,
            'error': str(e),
            'error_type': 'endpoint_error'
        })


@app.route('/download_pdf', methods=['POST'])
def download_pdf():
    """Generate and download PDF diet plan"""
    try:
        data = request.json
        user_data = data.get('user_data', {})
        result = data.get('result', {})

        pdf_data = diet_planner.generate_pdf_diet_plan(user_data, result)

        if pdf_data is None:
            return jsonify({
                'success': False,
                'error': 'Failed to generate PDF'
            }), 500

        response = make_response(pdf_data)
        response.headers['Content-Type'] = 'application/pdf'
        response.headers[
            'Content-Disposition'] = f'attachment; filename="diet_plan_{datetime.now().strftime("%Y%m%d_%H%M%S")}.pdf"'

        return response

    except Exception as e:
        print(f"Error in download_pdf endpoint: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/test_nutrition_db', methods=['GET'])
def test_nutrition_db():
    """Test nutrition database connections"""
    if not diet_planner.nutrition_db:
        return jsonify({
            'success': False,
            'error': 'Nutrition database not initialized',
            'usda_key_set': bool(USDA_API_KEY)
        })

    try:
        apple_nutrition = diet_planner.nutrition_db.get_food_nutrition_summary("apple")
        aspirin_interactions = diet_planner.nutrition_db.get_drug_food_guidance("aspirin")
        api_status = diet_planner.nutrition_db.test_api_connections()

        return jsonify({
            'success': True,
            'usda_test': {
                'food': 'apple',
                'calories_per_100g': apple_nutrition.get('calories_per_100g', 'N/A'),
                'verified': apple_nutrition.get('usda_verified', False)
            },
            'rxnorm_test': {
                'medication': 'aspirin',
                'found': aspirin_interactions.get('rxnorm_found', False),
                'restrictions_count': len(aspirin_interactions.get('food_restrictions', []))
            },
            'api_status': api_status,
            'database_ready': True
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'database_ready': False
        })


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'cache_size': len(diet_planner.response_cache),
        'nutrition_db_active': diet_planner.nutrition_db is not None
    })


# Add CORS headers for production
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response


# Production WSGI application
    if __name__ == '__main__':
        port = int(os.environ.get('PORT', 5001))
        app.run(host='0.0.0.0', port=port, debug=False)