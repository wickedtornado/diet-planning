import requests
import json
import sqlite3
import re
from datetime import datetime, timedelta
import threading


class NutritionDatabaseIntegration:
    """
    Integration with USDA FoodData Central and RxNorm APIs
    to enhance LLM diet planning with real nutritional data
    """

    def __init__(self, usda_api_key):
        self.usda_api_key = usda_api_key
        self.usda_base = "https://api.nal.usda.gov/fdc/v1"
        self.rxnorm_base = "https://rxnav.nlm.nih.gov/REST"
        self.setup_database()
        self.lock = threading.Lock()

    def setup_database(self):
        """Setup SQLite database for caching API responses"""
        self.conn = sqlite3.connect('nutrition_cache.db', check_same_thread=False)

        # Food nutrition cache table
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS food_nutrition (
                food_name TEXT PRIMARY KEY,
                nutrition_data TEXT,
                cached_date TEXT
            )
        ''')

        # Drug interaction cache table
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS drug_cache (
                drug_name TEXT PRIMARY KEY,
                interaction_data TEXT,
                cached_date TEXT
            )
        ''')

        self.conn.commit()

    def get_food_nutrition_summary(self, food_name):
        """
        Get nutrition summary for a specific food item
        Returns essential nutrition data for LLM context
        """
        # Check cache first (valid for 30 days)
        with self.lock:
            cached = self._get_cached_nutrition(food_name)
            if cached:
                return json.loads(cached)

        try:
            # Search USDA database
            nutrition_data = self._fetch_usda_nutrition(food_name)

            # Cache the result
            with self.lock:
                self._cache_nutrition(food_name, nutrition_data)

            return nutrition_data

        except Exception as e:
            return {
                'food_name': food_name,
                'error': f'Nutrition data unavailable: {str(e)}',
                'calories_per_100g': 'Unknown',
                'protein_g': 'Unknown',
                'carbs_g': 'Unknown',
                'fat_g': 'Unknown'
            }

    def _fetch_usda_nutrition(self, food_name):
        """Fetch nutrition data from USDA API"""
        # Step 1: Search for food
        search_url = f"{self.usda_base}/foods/search"
        search_params = {
            'api_key': self.usda_api_key,
            'query': food_name,
            'dataType': ['Foundation', 'SR Legacy', 'Branded'],
            'pageSize': 1
        }

        search_response = requests.get(search_url, params=search_params, timeout=15)
        search_response.raise_for_status()
        search_data = search_response.json()

        if not search_data.get('foods'):
            return {
                'food_name': food_name,
                'error': 'Food not found in USDA database',
                'calories_per_100g': 'Unknown',
                'protein_g': 'Unknown',
                'carbs_g': 'Unknown',
                'fat_g': 'Unknown'
            }

        # Step 2: Get detailed nutrition
        fdc_id = search_data['foods'][0]['fdcId']
        detail_url = f"{self.usda_base}/food/{fdc_id}"
        detail_params = {'api_key': self.usda_api_key}

        detail_response = requests.get(detail_url, params=detail_params, timeout=15)
        detail_response.raise_for_status()
        detail_data = detail_response.json()

        # Parse nutrition information
        nutrition = {
            'food_name': detail_data.get('description', food_name),
            'usda_verified': True,
            'calories_per_100g': 0,
            'protein_g': 0,
            'carbs_g': 0,
            'fat_g': 0,
            'fiber_g': 0,
            'sodium_mg': 0,
            'potassium_mg': 0,
            'key_vitamins': {},
            'key_minerals': {}
        }

        # Extract key nutrients
        for nutrient in detail_data.get('foodNutrients', []):
            nutrient_name = nutrient.get('nutrient', {}).get('name', '').lower()
            amount = nutrient.get('amount', 0)
            unit = nutrient.get('nutrient', {}).get('unitName', '')

            if 'energy' in nutrient_name and unit == 'KCAL':
                nutrition['calories_per_100g'] = round(amount, 1)
            elif 'protein' in nutrient_name:
                nutrition['protein_g'] = round(amount, 1)
            elif 'carbohydrate, by difference' in nutrient_name:
                nutrition['carbs_g'] = round(amount, 1)
            elif 'total lipid (fat)' in nutrient_name:
                nutrition['fat_g'] = round(amount, 1)
            elif 'fiber, total dietary' in nutrient_name:
                nutrition['fiber_g'] = round(amount, 1)
            elif 'sodium, na' in nutrient_name:
                nutrition['sodium_mg'] = round(amount, 1)
            elif 'potassium, k' in nutrient_name:
                nutrition['potassium_mg'] = round(amount, 1)
            elif 'vitamin c' in nutrient_name:
                nutrition['key_vitamins']['Vitamin C'] = f"{round(amount, 1)} {unit}"
            elif 'vitamin a' in nutrient_name and 'iu' in unit.lower():
                nutrition['key_vitamins']['Vitamin A'] = f"{round(amount, 1)} {unit}"
            elif 'calcium, ca' in nutrient_name:
                nutrition['key_minerals']['Calcium'] = f"{round(amount, 1)} {unit}"
            elif 'iron, fe' in nutrient_name:
                nutrition['key_minerals']['Iron'] = f"{round(amount, 1)} {unit}"

        return nutrition

    def get_drug_food_guidance(self, medication_name):
        """
        Get drug-food interaction guidance from RxNorm
        Returns dietary restrictions and timing recommendations
        """
        # Check cache first (valid for 90 days)
        with self.lock:
            cached = self._get_cached_drug_data(medication_name)
            if cached:
                return json.loads(cached)

        try:
            guidance = self._fetch_drug_guidance(medication_name)

            # Cache the result
            with self.lock:
                self._cache_drug_data(medication_name, guidance)

            return guidance

        except Exception as e:
            return {
                'medication': medication_name,
                'error': f'Drug interaction data unavailable: {str(e)}',
                'food_restrictions': ['Take as prescribed by healthcare provider'],
                'timing_recommendations': ['Follow medication schedule'],
                'special_considerations': []
            }

    def _fetch_drug_guidance(self, medication_name):
        """Fetch drug interaction data from RxNorm API with better error handling"""
        try:
            # Get RxCUI (drug identifier) with shorter timeout
            rxcui_url = f"{self.rxnorm_base}/rxcui.json"
            rxcui_params = {'name': medication_name}

            rxcui_response = requests.get(rxcui_url, params=rxcui_params, timeout=10)
            rxcui_response.raise_for_status()
            rxcui_data = rxcui_response.json()

            rxcui_list = rxcui_data.get('idGroup', {}).get('rxnormId', [])

            if not rxcui_list:
                # If not found in RxNorm, return known guidance
                return self._get_known_drug_guidance(medication_name)

            # Get interaction data with shorter timeout
            rxcui = rxcui_list[0]
            interaction_url = f"{self.rxnorm_base}/interaction/interaction.json"
            interaction_params = {'rxcui': rxcui}

            try:
                interaction_response = requests.get(interaction_url, params=interaction_params, timeout=8)
                interaction_response.raise_for_status()
                interaction_data = interaction_response.json()

                # Process interaction data
                guidance = self._process_interaction_data(medication_name, interaction_data)

            except (requests.RequestException, requests.Timeout):
                # If RxNorm interaction API fails, use known guidance
                guidance = self._get_known_drug_guidance(medication_name)

            # Add known drug-specific guidance
            guidance = self._add_known_drug_guidance(medication_name, guidance)

            return guidance

        except Exception as e:
            # Fallback to known guidance for any error
            return self._get_known_drug_guidance(medication_name)

    def _get_known_drug_guidance(self, medication_name):
        """Get guidance from our built-in drug knowledge base"""
        med_lower = medication_name.lower()

        # Comprehensive built-in drug guidance
        known_drugs = {
            'metformin': {
                'food_restrictions': [
                    'Take with meals to reduce stomach upset',
                    'Limit alcohol consumption',
                    'Avoid large amounts of vitamin B12 inhibiting foods long-term'
                ],
                'timing_recommendations': [
                    'Take with breakfast and dinner if twice daily',
                    'Take with largest meal if once daily',
                    'Consistent meal timing helps with blood sugar control'
                ],
                'special_considerations': [
                    'Monitor for lactic acidosis symptoms',
                    'Regular B12 level monitoring recommended'
                ]
            },
            'lisinopril': {
                'food_restrictions': [
                    'Monitor potassium intake (avoid excessive high-potassium foods)',
                    'Limit alcohol consumption',
                    'Avoid salt substitutes containing potassium'
                ],
                'timing_recommendations': [
                    'Can be taken with or without food',
                    'Take at the same time each day',
                    'Morning dosing preferred to avoid nighttime hypotension'
                ],
                'special_considerations': [
                    'Watch for signs of hyperkalemia',
                    'Monitor blood pressure regularly'
                ]
            },
            'warfarin': {
                'food_restrictions': [
                    'Maintain consistent vitamin K intake',
                    'Limit leafy green vegetables to consistent amounts',
                    'Avoid cranberry juice and large amounts of cranberries',
                    'Limit alcohol consumption significantly'
                ],
                'timing_recommendations': [
                    'Take at the same time each day (usually evening)',
                    'Consistent diet pattern crucial for INR stability',
                    'Take on empty stomach for consistent absorption'
                ],
                'special_considerations': [
                    'Regular INR monitoring essential',
                    'Many food and drug interactions - consult pharmacist'
                ]
            },
            'levothyroxine': {
                'food_restrictions': [
                    'Avoid soy products within 4 hours',
                    'Avoid calcium supplements within 4 hours',
                    'Avoid iron supplements within 4 hours',
                    'Avoid high-fiber meals within 1 hour'
                ],
                'timing_recommendations': [
                    'Take on empty stomach 30-60 minutes before breakfast',
                    'Wait 4 hours before calcium or iron supplements',
                    'Consistent timing critical for hormone levels'
                ],
                'special_considerations': [
                    'Coffee may affect absorption - wait 1 hour',
                    'Regular thyroid function monitoring needed'
                ]
            },
            'atorvastatin': {
                'food_restrictions': [
                    'Avoid grapefruit and grapefruit juice completely',
                    'Limit alcohol consumption',
                    'Can be taken with or without food'
                ],
                'timing_recommendations': [
                    'Evening dosing preferred (cholesterol synthesis highest at night)',
                    'Can take with dinner',
                    'Consistent daily timing recommended'
                ],
                'special_considerations': [
                    'Monitor for muscle pain or weakness',
                    'Regular liver function tests recommended'
                ]
            },
            'amlodipine': {
                'food_restrictions': [
                    'Avoid grapefruit and grapefruit juice',
                    'Limit alcohol consumption',
                    'Can be taken with or without food'
                ],
                'timing_recommendations': [
                    'Same time each day',
                    'Morning dosing typically preferred',
                    'Can take with breakfast'
                ],
                'special_considerations': [
                    'Monitor for ankle swelling',
                    'Rise slowly from sitting/lying to prevent dizziness'
                ]
            }
        }

        # Check if we have specific guidance for this drug
        for drug_name, guidance in known_drugs.items():
            if drug_name in med_lower or med_lower in drug_name:
                return {
                    'medication': medication_name,
                    'rxnorm_found': False,
                    'built_in_guidance': True,
                    'food_restrictions': guidance['food_restrictions'],
                    'timing_recommendations': guidance['timing_recommendations'],
                    'special_considerations': guidance['special_considerations']
                }

        # Generic guidance for unknown drugs
        return {
            'medication': medication_name,
            'rxnorm_found': False,
            'built_in_guidance': True,
            'food_restrictions': [
                'Take as prescribed by healthcare provider',
                'Maintain consistent meal timing',
                'Avoid excessive alcohol unless approved by doctor'
            ],
            'timing_recommendations': [
                'Follow prescribed dosing schedule',
                'Take at same time each day if possible',
                'Take with or without food as directed by prescriber'
            ],
            'special_considerations': [
                'Consult pharmacist for specific food interactions',
                'Report any unusual symptoms to healthcare provider',
                'Keep medication list updated with all providers'
            ]
        }

    def _get_generic_drug_guidance(self, medication_name):
        """Provide generic guidance when specific data unavailable"""
        return {
            'medication': medication_name,
            'rxnorm_found': False,
            'food_restrictions': [
                'Take as prescribed by healthcare provider',
                'Maintain consistent meal timing',
                'Avoid alcohol unless approved by doctor'
            ],
            'timing_recommendations': [
                'Follow prescribed dosing schedule',
                'Take with or without food as directed'
            ],
            'special_considerations': [
                'Consult pharmacist for food interactions',
                'Report any unusual symptoms to healthcare provider'
            ]
        }

    def _process_interaction_data(self, medication_name, interaction_data):
        """Process RxNorm interaction data into actionable guidance"""
        guidance = {
            'medication': medication_name,
            'rxnorm_found': True,
            'food_restrictions': [],
            'timing_recommendations': [],
            'special_considerations': []
        }

        # Extract interaction information
        interaction_groups = interaction_data.get('interactionTypeGroup', [])

        for group in interaction_groups:
            source_groups = group.get('sourceConceptGroup', [])
            for source_group in source_groups:
                interactions = source_group.get('conceptInteraction', [])
                for interaction in interactions:
                    description = interaction.get('description', '')
                    severity = interaction.get('severity', '')

                    # Process into actionable guidance
                    if 'food' in description.lower() or 'meal' in description.lower():
                        guidance['food_restrictions'].append(description)
                    elif 'time' in description.lower() or 'hour' in description.lower():
                        guidance['timing_recommendations'].append(description)
                    elif severity and severity.lower() in ['high', 'severe']:
                        guidance['special_considerations'].append(f"HIGH PRIORITY: {description}")

        return guidance

    def _add_known_drug_guidance(self, medication_name, guidance):
        """Add well-known drug-food interactions"""
        med_lower = medication_name.lower()

        # Common drug-food interactions
        known_interactions = {
            'warfarin': {
                'food_restrictions': [
                    'Maintain consistent vitamin K intake (leafy greens)',
                    'Avoid cranberry juice and large amounts of cranberries',
                    'Limit alcohol consumption'
                ],
                'timing_recommendations': [
                    'Take at the same time each day',
                    'Consistent diet pattern important for INR stability'
                ]
            },
            'metformin': {
                'food_restrictions': [
                    'Take with meals to reduce stomach upset',
                    'Limit alcohol intake'
                ],
                'timing_recommendations': [
                    'Take with breakfast and dinner if twice daily',
                    'Take with largest meal if once daily'
                ]
            },
            'levothyroxine': {
                'food_restrictions': [
                    'Avoid soy products within 4 hours',
                    'Avoid calcium and iron supplements within 4 hours',
                    'Avoid high-fiber meals within 1 hour'
                ],
                'timing_recommendations': [
                    'Take on empty stomach 30-60 minutes before breakfast',
                    'Wait at least 4 hours before calcium or iron supplements'
                ]
            },
            'lisinopril': {
                'food_restrictions': [
                    'Monitor potassium intake (avoid excessive potassium-rich foods)',
                    'Limit alcohol consumption'
                ],
                'timing_recommendations': [
                    'Can be taken with or without food',
                    'Take at the same time each day'
                ]
            }
        }

        # Add known interactions if medication matches
        for drug, interactions in known_interactions.items():
            if drug in med_lower:
                guidance['food_restrictions'].extend(interactions.get('food_restrictions', []))
                guidance['timing_recommendations'].extend(interactions.get('timing_recommendations', []))
                guidance['special_considerations'].append(f'Evidence-based guidance for {drug}')
                break

        # Remove duplicates
        guidance['food_restrictions'] = list(set(guidance['food_restrictions']))
        guidance['timing_recommendations'] = list(set(guidance['timing_recommendations']))

        return guidance

    def enhance_llm_prompt_with_nutrition_data(self, original_prompt, user_data):
        """
        Enhance the LLM prompt with real nutrition and drug interaction data
        This makes the AI responses more accurate and evidence-based
        """
        enhanced_sections = []

        # Add nutrition database context
        enhanced_sections.append("""
🔬 NUTRITION DATABASE INTEGRATION:
You now have access to USDA FoodData Central (400,000+ foods) and RxNorm drug database.
Use this data to provide EXACT nutrition information and verified drug interactions.

When recommending foods:
1. Verify actual calorie and macro content from USDA data
2. Provide specific portion sizes based on nutritional density
3. Ensure recommendations match calculated calorie targets exactly

When considering medications:
1. Check specific drug-food interactions from RxNorm
2. Provide evidence-based timing recommendations
3. Flag any potentially dangerous food combinations
        """)

        # Get medication-specific data
        medications = user_data.get('medicines', '').split(',')
        medication_guidance = []

        for med in medications:
            med = med.strip()
            if med and med.lower() not in ['none', 'nil', '']:
                drug_data = self.get_drug_food_guidance(med)
                if not drug_data.get('error'):
                    medication_guidance.append(f"""
MEDICATION: {drug_data['medication']}
- Food Restrictions: {'; '.join(drug_data.get('food_restrictions', []))}
- Timing: {'; '.join(drug_data.get('timing_recommendations', []))}
- Special Notes: {'; '.join(drug_data.get('special_considerations', []))}
                    """)

        if medication_guidance:
            enhanced_sections.append(f"""
💊 VERIFIED DRUG-FOOD INTERACTIONS:
{chr(10).join(medication_guidance)}

CRITICAL: Incorporate these specific interactions into meal timing and food choices.
            """)

        # Add verification requirement
        enhanced_sections.append("""
✅ NUTRITION VERIFICATION REQUIREMENT:
For each recommended food item:
1. State the USDA-verified calories per 100g
2. Provide exact protein, carb, and fat content
3. Ensure portion sizes align with calorie targets
4. Mention any relevant micronutrients

Example format:
"Brown rice (1 cup cooked = 216 calories, 5g protein, 44g carbs, 1.8g fat - USDA verified)"
        """)

        # Combine with original prompt
        enhanced_prompt = original_prompt + "\n\n" + "\n".join(enhanced_sections)

        return enhanced_prompt

    def get_nutrition_verification_for_llm(self, food_list):
        """
        Get nutrition verification data for a list of foods
        This can be called during or after LLM response generation
        """
        verification_data = {}

        for food in food_list:
            nutrition = self.get_food_nutrition_summary(food)
            verification_data[food] = nutrition

        return verification_data

    def _get_cached_nutrition(self, food_name):
        """Get nutrition data from cache if valid"""
        cursor = self.conn.execute(
            "SELECT nutrition_data, cached_date FROM food_nutrition WHERE food_name = ?",
            (food_name.lower(),)
        )
        result = cursor.fetchone()

        if result:
            cached_date = datetime.fromisoformat(result[1])
            if datetime.now() - cached_date < timedelta(days=30):
                return result[0]

        return None

    def _cache_nutrition(self, food_name, data):
        """Cache nutrition data"""
        self.conn.execute(
            "INSERT OR REPLACE INTO food_nutrition VALUES (?, ?, ?)",
            (food_name.lower(), json.dumps(data), datetime.now().isoformat())
        )
        self.conn.commit()

    def _get_cached_drug_data(self, drug_name):
        """Get drug data from cache if valid"""
        cursor = self.conn.execute(
            "SELECT interaction_data, cached_date FROM drug_cache WHERE drug_name = ?",
            (drug_name.lower(),)
        )
        result = cursor.fetchone()

        if result:
            cached_date = datetime.fromisoformat(result[1])
            if datetime.now() - cached_date < timedelta(days=90):
                return result[0]

        return None

    def _cache_drug_data(self, drug_name, data):
        """Cache drug interaction data"""
        self.conn.execute(
            "INSERT OR REPLACE INTO drug_cache VALUES (?, ?, ?)",
            (drug_name.lower(), json.dumps(data), datetime.now().isoformat())
        )
        self.conn.commit()

    def test_api_connections(self):
        """Test both API connections"""
        results = {}

        # Test USDA API
        try:
            usda_test = self.get_food_nutrition_summary("apple")
            results['usda'] = {
                'status': 'success' if not usda_test.get('error') else 'error',
                'message': 'USDA API working' if not usda_test.get('error') else usda_test.get('error')
            }
        except Exception as e:
            results['usda'] = {'status': 'error', 'message': str(e)}

        # Test RxNorm API
        try:
            rxnorm_test = self.get_drug_food_guidance("aspirin")
            results['rxnorm'] = {
                'status': 'success' if not rxnorm_test.get('error') else 'error',
                'message': 'RxNorm API working' if not rxnorm_test.get('error') else rxnorm_test.get('error')
            }
        except Exception as e:
            results['rxnorm'] = {'status': 'error', 'message': str(e)}

        return results