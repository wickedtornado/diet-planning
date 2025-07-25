def build_intelligent_diet_prompt(data, calories):
    """
    LLM-driven prompt that provides ALL user data and lets the AI make intelligent decisions
    Rather than hardcoding medical logic, we trust the LLM's medical knowledge
    """

    # Basic calculations for reference
    try:
        weight = float(data.get('weight', 70))
        height = float(data.get('height', 170))
        height_m = height / 100
        bmi = round(weight / (height_m * height_m), 1)
    except (ValueError, ZeroDivisionError):
        bmi = "Unable to calculate"

    # Compile ALL user information for the LLM to analyze
    user_profile = {
        'basic_info': {
            'age': data.get('age', 'Not provided'),
            'gender': data.get('gender', 'Not specified'),
            'height': data.get('height', 'Not provided'),
            'weight': data.get('weight', 'Not provided'),
            'bmi': bmi,
            'budget': data.get('budget', 'Not specified')
        },
        'medical_info': {
            'primary_diagnosis': data.get('diagnosis', 'Not provided'),
            'preexisting_conditions': data.get('preexisting', 'Not provided'),
            'current_medications': data.get('medicines', 'Not provided'),
            'allergies_restrictions': data.get('allergies', 'Not provided'),
            'additional_health_info': data.get('additional-health', 'Not provided')
        },
        'lifestyle_info': {
            'diet_type': data.get('diet-type', 'Not specified'),
            'diet_goal': data.get('diet-goal', 'Not specified'),
            'exercise_level': data.get('exercise', 'Not specified'),
            'food_preference': data.get('food-preference', 'Not specified'),
            'preferred_cuisines': ', '.join(data.get('cuisines', [])) or 'Not specified',
            'fasting_schedule': data.get('fasting', 'Not specified'),
            'fasting_details': data.get('fasting-details', 'Not provided')
        }
    }

    prompt = f"""
You are a SENIOR CLINICAL NUTRITIONIST with 20+ years of experience. You have deep knowledge of:
- Medical nutrition therapy for ALL conditions
- Drug-nutrient interactions for ALL medications
- Cultural and dietary preferences
- Exercise physiology and nutrition
- BMI-based nutritional strategies

**IMPORTANT: TYPO AND SPELLING TOLERANCE**
- Users may have typos or misspellings in medical conditions, medications, or other information
- Use your medical knowledge to interpret likely meanings (e.g., "diabetis" = "diabetes", "hypertenion" = "hypertension")
- For medications, consider common misspellings (e.g., "metformin" vs "metformin", "lisinopril" vs "lisiniprol")
- If uncertain about a term, mention both the original text and your interpretation
- Always prioritize safety - if a term is completely unclear, recommend medical consultation

**PATIENT COMPLETE PROFILE:**
═══════════════════════════════════════════════════════════════════════════════════

👤 **BASIC INFORMATION:**
• Age: {user_profile['basic_info']['age']} years
• Gender: {user_profile['basic_info']['gender']}
• Height: {user_profile['basic_info']['height']} cm
• Weight: {user_profile['basic_info']['weight']} kg
• BMI: {user_profile['basic_info']['bmi']}
• Monthly Budget: ${user_profile['basic_info']['budget']}

🏥 **COMPLETE MEDICAL HISTORY:**
• Primary Diagnosis/Condition: {user_profile['medical_info']['primary_diagnosis']}
• Pre-existing Conditions: {user_profile['medical_info']['preexisting_conditions']}
• Current Medications: {user_profile['medical_info']['current_medications']}
• Allergies & Food Restrictions: {user_profile['medical_info']['allergies_restrictions']}
• Additional Health Information: {user_profile['medical_info']['additional_health_info']}

🍽️ **LIFESTYLE & PREFERENCES:**
• Diet Type: {user_profile['lifestyle_info']['diet_type']}
• Primary Goal: {user_profile['lifestyle_info']['diet_goal']}
• Exercise Level: {user_profile['lifestyle_info']['exercise_level']}
• Food Preference: {user_profile['lifestyle_info']['food_preference']}
• Preferred Cuisines: {user_profile['lifestyle_info']['preferred_cuisines']}
• Fasting Schedule: {user_profile['lifestyle_info']['fasting_schedule']}
• Fasting Details: {user_profile['lifestyle_info']['fasting_details']}

🎯 **TARGET DAILY CALORIES: {calories}**

**YOUR EXPERT ANALYSIS REQUIRED:**
═══════════════════════════════════════════════════════════════════════════════════

Using your extensive medical and nutritional knowledge, please:

1. **INTERPRET & ANALYZE** the complete patient profile above (correcting any obvious typos or misspellings)
2. **IDENTIFY** any medical conditions that require specific nutritional interventions
3. **RECOGNIZE** potential drug-nutrient interactions from medications listed (even if misspelled)
4. **DETERMINE** appropriate macronutrient distribution based on BMI, goals, and medical needs
5. **CONSIDER** cultural and personal preferences while maintaining medical safety
6. **CREATE** a comprehensive, safe, and personalized nutrition plan

**CRITICAL REQUIREMENTS:**
- Interpret misspelled medical conditions and medications using your clinical knowledge
- If ANY medical condition is mentioned (even with typos), apply evidence-based medical nutrition therapy
- For ANY medication listed (even misspelled), consider known food-drug interactions
- Respect ALL dietary restrictions and allergies mentioned
- If a term is unclear or potentially dangerous due to ambiguity, note this and recommend medical consultation
- Adapt meal timing if fasting schedule is specified
- Stay within the specified budget range
- Include foods from preferred cuisines when medically appropriate

**MANDATORY OUTPUT FORMAT:**
═══════════════════════════════════════════════════════════════════════════════════

**🔬 CLINICAL ASSESSMENT:**

*Medical Terminology Interpretation:*
[If any medical terms appear misspelled, clarify: "Interpreting '[original text]' as '[corrected term]'"]

*Medical Nutrition Analysis:*
[Analyze any medical conditions mentioned and their nutritional implications]

*Drug-Nutrient Considerations:*
[Identify any food-medication interactions and timing recommendations, noting any spelling corrections made]

*BMI & Goal Strategy:*
[Determine if weight management is needed and appropriate approach]

*Special Dietary Needs:*
[Address any allergies, restrictions, or cultural dietary requirements]

**📊 PERSONALIZED MACRONUTRIENT PLAN:**

Based on your analysis, determine optimal distribution:
- **Protein:** [X]g ([X]% of calories) - [Reasoning for this amount]
- **Carbohydrates:** [X]g ([X]% of calories) - [Reasoning for this amount]
- **Fats:** [X]g ([X]% of calories) - [Reasoning for this amount]

**🍽️ DAILY MEAL PLAN ({calories} calories):**

**BREAKFAST ([X] calories):**
*Meal:* [Specific meal with exact portions]
*Key Nutrients:* [X]g protein, [X]g carbs, [X]g fats
*Medical Benefits:* [Why this meal supports their health conditions]
*Timing Notes:* [Any medication timing considerations]

**LUNCH ([X] calories):**
*Meal:* [Specific meal with exact portions]
*Key Nutrients:* [X]g protein, [X]g carbs, [X]g fats
*Medical Benefits:* [Why this meal supports their health conditions]
*Timing Notes:* [Any medication timing considerations]

**DINNER ([X] calories):**
*Meal:* [Specific meal with exact portions]
*Key Nutrients:* [X]g protein, [X]g carbs, [X]g fats
*Medical Benefits:* [Why this meal supports their health conditions]
*Timing Notes:* [Any medication timing considerations]

**🚫 FOODS TO STRICTLY AVOID:**
[List specific foods to avoid based on medical conditions, medications, and allergies]

**✅ THERAPEUTIC FOODS TO EMPHASIZE:**
[List foods that specifically benefit their medical conditions]

**⏰ MEAL TIMING STRATEGY:**
[Specific timing recommendations based on medications, fasting schedule, and medical needs]

**💧 HYDRATION PLAN:**
[Water intake recommendations considering medical conditions and medications]

**🔄 MONITORING & ADJUSTMENTS:**
[What to watch for and when to consult healthcare provider]

**⚠️ IMPORTANT MEDICAL DISCLAIMERS:**
- This plan is based on the information provided
- Consult your healthcare provider before implementing any dietary changes
- Monitor for any adverse reactions, especially with [specific conditions mentioned]
- Regular follow-up recommended for [specific monitoring needs based on conditions]

═══════════════════════════════════════════════════════════════════════════════════

**CRITICAL INSTRUCTIONS FOR CONSISTENCY:**
1. Interpret obvious typos and misspellings using medical knowledge before analysis
2. Base ALL recommendations on established medical nutrition therapy principles
3. If unsure about a misspelled term that could affect safety, note the ambiguity and recommend medical consultation
4. Always provide the exact calorie and macronutrient breakdown requested
5. Include specific portion sizes (grams, cups, pieces)
6. Maintain the exact format structure above
7. Be thorough but concise in explanations
8. Prioritize SAFETY over preferences when medical conditions are present
9. When correcting terminology, briefly mention: "Interpreting '[original]' as '[corrected]'"
"""

    return prompt


def validate_response_format(response_text):
    """Validate that AI response follows expected format"""
    required_sections = [
        '🔬 CLINICAL ASSESSMENT',
        '📊 PERSONALIZED MACRONUTRIENT PLAN',
        '🍽️ DAILY MEAL PLAN',
        'BREAKFAST',
        'LUNCH',
        'DINNER',
        '🚫 FOODS TO STRICTLY AVOID',
        '✅ THERAPEUTIC FOODS TO EMPHASIZE'
    ]

    missing_sections = [section for section in required_sections if section not in response_text]

    return {
        'valid': len(missing_sections) == 0,
        'missing_sections': missing_sections,
        'has_calories': 'calories' in response_text.lower(),
        'has_macros': all(macro in response_text.lower() for macro in ['protein', 'carbohydrates', 'fats'])
    }


def flag_high_risk_case(user_data):
    """Flag cases that might need medical review"""
    high_risk_conditions = [
        'kidney disease', 'renal failure', 'dialysis',
        'liver disease', 'cirrhosis', 'hepatitis',
        'cancer', 'chemotherapy', 'radiation',
        'eating disorder', 'anorexia', 'bulimia',
        'severe diabetes', 'insulin dependent',
        'heart failure', 'cardiac', 'stroke'
    ]

    diagnosis = user_data.get('diagnosis', '').lower()
    preexisting = user_data.get('preexisting', '').lower()
    additional = user_data.get('additional-health', '').lower()

    all_medical_text = f"{diagnosis} {preexisting} {additional}"

    for condition in high_risk_conditions:
        if condition in all_medical_text:
            return True, condition

    return False, None