import os
import pandas as pd
from pathlib import Path

def get_contest_numbers_and_themes():
    """Get all image files and extract contest numbers and themes."""
    # Read the CSV file to get themes
    df = pd.read_csv('semantic_similarity_with_svg_path.csv')
    
    # Get unique contest numbers and their themes
    contest_themes = df[['contest', 'theme']].drop_duplicates()
    contest_theme_dict = dict(zip(contest_themes['contest'], contest_themes['theme']))
    
    # Get unique themes for filter buttons
    unique_themes = sorted(df['theme'].unique())
    
    image_dir = Path('contest_images')
    contest_numbers = []
    
    if not image_dir.exists():
        print(f"Warning: {image_dir} directory not found")
        return contest_numbers, [], {}
    
    for file in image_dir.glob('*_Dashboard.jpg'):
        try:
            contest_number = int(file.name.split('_')[0])
            # Verify that both the image and the contest page exist
            if (image_dir / f"{contest_number}_Dashboard.jpg").exists() and \
               (Path('contest_pages') / f"contest_{contest_number}.html").exists():
                contest_numbers.append(contest_number)
        except ValueError:
            continue
    
    return sorted(contest_numbers), unique_themes, contest_theme_dict

def generate_theme_buttons(themes):
    """Generate HTML for theme filter buttons."""
    buttons = ['<button class="theme-button active" data-theme="all">All</button>']
    for theme in themes:
        buttons.append(f'<button class="theme-button" data-theme="{theme}">{theme.title()}</button>')
    return '\n'.join(buttons)

def generate_gallery_items(contest_numbers, contest_theme_dict):
    """Generate HTML for gallery items."""
    items = []
    for number in contest_numbers:
        theme = contest_theme_dict.get(number, '')
        items.append(f'''
            <a href="detail.html?contest={number}" class="contest-card" data-theme="{theme}">
                <img src="contest_images/{number}_Dashboard.jpg" alt="Contest #{number}" loading="lazy">
                <div class="contest-info">
                    <span class="contest-number">Contest #{number}</span>
                    <span class="contest-theme">{theme.title()}</span>
                </div>
            </a>
        ''')
    return '\n'.join(items)

def main():
    # Get contest numbers and themes
    contest_numbers, themes, contest_theme_dict = get_contest_numbers_and_themes()
    
    if not contest_numbers:
        print("Error: No valid contests found")
        return
    
    # Read the index template
    with open('index.html', 'r', encoding='utf-8') as f:
        template = f.read()
    
    # Generate theme buttons and gallery items
    theme_buttons = generate_theme_buttons(themes)
    gallery_items = generate_gallery_items(contest_numbers, contest_theme_dict)
    
    # Replace placeholders with theme buttons and gallery items
    html = template.replace('<!-- Theme buttons will be added here -->', theme_buttons)
    html = html.replace('<!-- Contest cards will be added here by the Python script -->', gallery_items)
    
    # Save the modified index file
    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"Generated index page with {len(contest_numbers)} contests and {len(themes)} themes")

if __name__ == '__main__':
    main() 