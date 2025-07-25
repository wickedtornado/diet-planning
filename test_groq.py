from groq import Groq

# Initialize Groq client with your API key
client = Groq(
    api_key="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"  # Replace with your actual API key
)


def test_basic_connection():
    try:
        response = client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": "Hello! Can you help with diet planning?"
                }
            ],
            model="llama3-70b-8192",
            temperature=0.3
        )

        print("✅ SUCCESS! Groq API is working!")
        print("Response:", response.choices[0].message.content)
        return True

    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def test_diet_planning():
    diet_prompt = """
    Create a 3-meal diet plan for:
    - 35-year-old male, 80kg, 175cm
    - Type 2 Diabetes
    - Goal: Weight loss
    - Vegetarian, no nuts
    - Moderate exercise

    Provide:
    1. Breakfast with calories
    2. Lunch with calories  
    3. Dinner with calories

    Format as simple text, not JSON.
    """

    try:
        response = client.chat.completions.create(
            messages=[{"role": "user", "content": diet_prompt}],
            model="llama3-70b-8192",
            temperature=0.3,
            max_tokens=1000
        )

        print("\n🍽️ DIET PLAN GENERATED:")
        print("=" * 50)
        print(response.choices[0].message.content)
        print("=" * 50)

    except Exception as e:
        print(f"❌ Diet planning error: {e}")


if __name__ == "__main__":
    if test_basic_connection():
        print("\n" + "=" * 50)
        test_diet_planning()