import os
from bs4 import BeautifulSoup
import re
import json


def extract_question_data(html_file):
    """Extract question data from HTML file."""

    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()

    soup = BeautifulSoup(html_content, 'html.parser')

    # Find question container
    question_item = soup.find('div', class_='question-item')

    # Extract question text from the question-item-ask section
    question_ask = question_item.find('p', class_='question-item-ask')

    # Extract options
    options = {}
    option_divs = question_item.find_all('div', recursive=False)

    # Filter out divs with classes (keeping only the option divs)
    option_divs = [div for div in option_divs if not div.get('class')]

    # Process the option divs
    for option_div in option_divs:
        option_text = option_div.text.strip()
        # Extract option letter and content
        match = re.match(r'([A-E])\)\s*(.*)', option_text)
        if match:
            option_letter, option_content = match.groups()
            options[option_letter] = option_content.strip()

    # Create the dictionary with all the extracted data
    question_data = {
        'question': question_ask,
        'options': options
    }

    return question_data


if __name__ == "__main__":
    # Extract data from sample_question.html
    question_data = extract_question_data('sample_question.html')

    # Save to JSON file
    with open('extracted_questions.json', 'w', encoding='utf-8') as f:
        json.dump([question_data], f, indent=2, ensure_ascii=False)
