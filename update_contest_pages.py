import os
import csv
from bs4 import BeautifulSoup

def remove_claude_captions():
    """Remove all Claude captions from contest pages"""
    contest_files = [f for f in os.listdir('contest_pages') if f.startswith('contest_') and f.endswith('.html')]
    print(f"Found {len(contest_files)} contest files to process")
    
    for contest_file in contest_files:
        with open(f'contest_pages/{contest_file}', 'r') as f:
            soup = BeautifulSoup(f, 'html.parser')
        
        # Find and remove all Claude caption divs
        ai_captions = soup.find('div', class_='ai-captions')
        if ai_captions:
            claude_divs = ai_captions.find_all('div', class_='ai-model')
            for div in claude_divs:
                if div.find('h3', string='Claude'):
                    div.decompose()
                    print(f"Removed Claude caption from {contest_file}")
        
        # Write updated HTML
        with open(f'contest_pages/{contest_file}', 'w') as f:
            f.write(str(soup))

def add_claude_captions():
    """Add Claude captions from CSV file"""
    # Read Claude's captions from the CSV file
    claude_captions = {}
    with open('/Users/chivo/Downloads/data_studio/project4/cartoon/claude_captions_trimmed.csv', 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            contest_num = row['contest'].split('_')[0]
            caption = row['caption_cleaned'].strip()
            if caption:  # Only add non-empty captions
                claude_captions[contest_num] = caption
                print(f"Loaded caption for contest {contest_num}")
    
    # Process each contest page
    contest_files = [f for f in os.listdir('contest_pages') if f.startswith('contest_') and f.endswith('.html')]
    print(f"Found {len(contest_files)} contest files to process")
    
    for contest_file in contest_files:
        contest_num = contest_file.split('_')[1].split('.')[0]
        
        # Skip if we don't have a caption for this contest
        if contest_num not in claude_captions:
            print(f"Skipping contest {contest_num} - no caption found")
            continue
        
        print(f"\nProcessing contest {contest_num}...")
        
        # Read and parse HTML
        with open(f'contest_pages/{contest_file}', 'r') as f:
            soup = BeautifulSoup(f, 'html.parser')
        
        # Find AI captions section
        ai_captions = soup.find('div', class_='ai-captions')
        if ai_captions:
            # Create new Claude caption div
            claude_div = soup.new_tag('div', attrs={'class': 'ai-model'})
            claude_h3 = soup.new_tag('h3')
            claude_h3.string = 'Claude'
            claude_caption = soup.new_tag('div', attrs={'class': 'ai-caption'})
            claude_caption.string = claude_captions[contest_num]
            
            # Add elements to the div
            claude_div.append(claude_h3)
            claude_div.append(claude_caption)
            
            # Add Claude div after ChatGPT div
            chatgpt_div = ai_captions.find('div', class_='ai-model')
            if chatgpt_div:
                chatgpt_div.insert_after(claude_div)
                print(f"Added Claude caption for contest {contest_num}")
        
        # Write updated HTML
        with open(f'contest_pages/{contest_file}', 'w') as f:
            f.write(str(soup))
        print(f"Saved updates for contest {contest_num}")

# First remove all Claude captions
print("Removing all existing Claude captions...")
remove_claude_captions()

# Then add them back from the CSV file
print("\nAdding Claude captions from CSV file...")
add_claude_captions()

print("\nAll contest pages updated successfully!") 