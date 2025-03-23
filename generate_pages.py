import pandas as pd
import os
from pathlib import Path

def read_caption_data(csv_file):
    return pd.read_csv(csv_file)

def generate_human_caption_html(number, caption, funny_votes, unfunny_votes, total_votes):
    return f'''
    <tr>
        <td class="caption-number">{number}</td>
        <td>{caption}</td>
        <td class="vote-cell">{funny_votes}</td>
        <td class="vote-cell">{unfunny_votes}</td>
        <td class="vote-cell">{total_votes}</td>
    </tr>
    '''

def generate_ai_caption_html(caption):
    return f'''
    <div class="ai-caption">{caption}</div>
    '''

def generate_contest_page(contest_num, human_captions_data, chatgpt_caption, claude_caption, svg_path=None):
    with open('detail.html', 'r') as f:
        template = f.read()
    
    # Generate human captions HTML
    human_captions_html = ''
    for i, (caption, funny_votes, unfunny_votes, total_votes) in enumerate(human_captions_data, 1):
        if caption and isinstance(caption, str) and caption.strip():
            human_captions_html += generate_human_caption_html(
                i, 
                caption.strip(), 
                funny_votes, 
                unfunny_votes, 
                total_votes
            )
    
    if not human_captions_html:
        human_captions_html = '<tr><td colspan="5">No human captions available</td></tr>'

    # Generate AI captions HTML
    chatgpt_html = generate_ai_caption_html(chatgpt_caption) if chatgpt_caption else '<div class="ai-caption">No OpenAI caption available</div>'
    claude_html = generate_ai_caption_html(claude_caption) if claude_caption else '<div class="ai-caption">No Claude caption available</div>'
    
    # Replace placeholders in template
    page_content = template.replace('[NUMBER]', str(contest_num))
    
    # Insert captions into their respective sections
    page_content = page_content.replace('<!-- Human captions will be added here -->', human_captions_html)
    page_content = page_content.replace('<!-- ChatGPT caption will be added here -->', chatgpt_html)
    page_content = page_content.replace('<!-- Claude caption will be added here -->', claude_html)
    
    # Replace SVG path if available, adjusting the path to be relative to contest_pages
    if svg_path and isinstance(svg_path, str):
        adjusted_svg_path = f"../{svg_path}"  # Add ../ to go up one directory
        page_content = page_content.replace('[SVG_PATH]', adjusted_svg_path)
    else:
        page_content = page_content.replace('[SVG_PATH]', '')
    
    return page_content

def main():
    # Create contest_pages directory if it doesn't exist
    os.makedirs('contest_pages', exist_ok=True)
    
    # Read both CSV files
    df_similarity = pd.read_csv('semantic_similarity_with_svg_path.csv')
    df_votes = pd.read_csv('captions_long_format.csv')
    
    # Process each contest
    processed_contests = set()
    for _, row in df_similarity.iterrows():
        contest_num = row['contest']
        if contest_num in processed_contests:
            continue
            
        # Get all captions for this contest from both dataframes
        contest_data_similarity = df_similarity[df_similarity['contest'] == contest_num]
        contest_data_votes = df_votes[df_votes['contest'] == contest_num]
        
        # Get SVG path for this contest
        svg_path = contest_data_similarity['svg_path'].iloc[0] if 'svg_path' in contest_data_similarity.columns else None
        
        # Get human captions with votes
        human_captions_data = []
        human_data = contest_data_votes[contest_data_votes['model'].str.lower() == 'human']
        
        # Sort by funny votes in descending order
        human_data_sorted = human_data.sort_values('funny_votes', ascending=False)
        
        for _, caption_row in human_data_sorted.iterrows():
            if pd.notna(caption_row['caption']):
                caption = caption_row['caption'].strip()
                funny = int(caption_row['funny_votes'])
                unfunny = int(caption_row['unfunny_votes'])
                total = int(caption_row['votes'])
                if caption and (caption, funny, unfunny, total) not in human_captions_data:  # Avoid duplicates
                    human_captions_data.append((caption, funny, unfunny, total))
        
        # Take top 5 by votes
        human_captions_data = human_captions_data[:5]
        
        # Get AI captions from similarity data
        chatgpt_caption = None
        claude_caption = None
        for _, caption_row in contest_data_similarity.iterrows():
            if pd.notna(caption_row['ai_caption']):
                model = str(caption_row['ai_model']).lower()
                if 'chatgpt' in model or 'gpt' in model:
                    chatgpt_caption = caption_row['ai_caption'].strip()
                elif 'claude' in model:
                    claude_caption = caption_row['ai_caption'].strip()
        
        # Generate and save the contest page
        page_content = generate_contest_page(
            contest_num,
            human_captions_data,
            chatgpt_caption,
            claude_caption,
            svg_path
        )
        
        output_path = f'contest_pages/contest_{contest_num}.html'
        with open(output_path, 'w') as f:
            f.write(page_content)
            
        processed_contests.add(contest_num)
    
    print(f"Generated {len(processed_contests)} contest pages")

if __name__ == "__main__":
    main() 