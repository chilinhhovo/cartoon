document.addEventListener('DOMContentLoaded', function() {
    // Get contest number from URL
    const urlParams = new URLSearchParams(window.location.search);
    const contestNumber = urlParams.get('contest');

    if (!contestNumber) {
        window.location.href = 'index.html';
        return;
    }

    // Update contest number in header
    document.getElementById('contest-number').textContent = contestNumber;

    // Load contest data
    Promise.all([
        fetch('semantic_similarity_with_svg_path.csv'),
        fetch('combined_captions_with_hf_sentiment.csv'),
        fetch('contests_with_model_winner.csv')
    ])
    .then(responses => Promise.all(responses.map(r => r.text())))
    .then(([similarityData, sentimentData, modelData]) => {
        // Parse CSV data
        const similarityRows = parseCSV(similarityData);
        const sentimentRows = parseCSV(sentimentData);
        const modelRows = parseCSV(modelData);

        // Find contest data
        const contestData = similarityRows.find(row => row.contest_number === contestNumber);
        const contestSentiment = sentimentRows.filter(row => row.contest_number === contestNumber);
        const modelPerformance = modelRows.find(row => row.contest_number === contestNumber);

        if (!contestData) {
            throw new Error('Contest not found');
        }

        // Update image and theme
        document.getElementById('contest-image').src = `contest_images/${contestNumber}.jpg`;
        document.getElementById('contest-theme').textContent = contestData.theme;

        // Load and display SVG chart
        fetch(contestData.svg_path)
            .then(response => response.text())
            .then(svgContent => {
                document.getElementById('similarity-chart').innerHTML = svgContent;
            });

        // Populate AI captions
        const aiCaptions = document.getElementById('ai-captions');
        const aiModels = [
            {
                name: 'ChatGPT',
                caption: modelPerformance.chatgpt_caption || 'No ChatGPT caption available'
            },
            {
                name: 'Claude',
                caption: modelPerformance.claude_caption || 'No Claude caption available'
            },
            {
                name: 'DeepSeek',
                caption: modelPerformance.deepseek_caption || 'No DeepSeek caption available'
            }
        ];

        aiModels.forEach(model => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="model-name">${model.name}</td>
                <td>${model.caption}</td>
            `;
            aiCaptions.appendChild(tr);
        });

        // Update metrics
        document.getElementById('avg-similarity').textContent = 
            formatSimilarity((parseFloat(contestData.chatgpt_similarity) + 
                            parseFloat(contestData.claude_similarity) + 
                            parseFloat(contestData.deepseek_similarity)) / 3);

        document.getElementById('sentiment-dist').textContent = 
            calculateSentimentDistribution(contestSentiment);

        document.getElementById('theme-confidence').textContent = 
            formatPercentage(contestData.theme_confidence);

        document.getElementById('model-performance').textContent = 
            determineTopModel(contestData);
    })
    .catch(error => {
        console.error('Error loading contest data:', error);
        alert('Error loading contest data. Please try again.');
    });
});

function parseCSV(csvText) {
    const lines = csvText.split('\n');
    const headers = lines[0].split(',');
    return lines.slice(1)
        .filter(line => line.trim())
        .map(line => {
            const values = line.split(',');
            return headers.reduce((obj, header, i) => {
                obj[header.trim()] = values[i]?.trim() || '';
                return obj;
            }, {});
        });
}

function getSentiment(sentimentData, source) {
    const entry = sentimentData.find(row => row.source === source);
    return entry ? entry.sentiment : 'N/A';
}

function formatSentiment(sentiment) {
    if (sentiment === 'N/A') return 'N/A';
    const value = parseFloat(sentiment);
    const label = value > 0 ? 'Positive' : value < 0 ? 'Negative' : 'Neutral';
    return `${label} (${value.toFixed(2)})`;
}

function formatSimilarity(similarity) {
    return (similarity * 100).toFixed(1) + '%';
}

function formatPercentage(value) {
    return (parseFloat(value) * 100).toFixed(1) + '%';
}

function calculateSentimentDistribution(sentimentData) {
    const sentiments = sentimentData.map(row => parseFloat(row.sentiment));
    const positive = sentiments.filter(s => s > 0).length;
    const negative = sentiments.filter(s => s < 0).length;
    const neutral = sentiments.filter(s => s === 0).length;
    return `${positive}+ ${neutral}= ${negative}-`;
}

function determineTopModel(contestData) {
    const similarities = [
        { model: 'ChatGPT', value: parseFloat(contestData.chatgpt_similarity) },
        { model: 'Claude', value: parseFloat(contestData.claude_similarity) },
        { model: 'DeepSeek', value: parseFloat(contestData.deepseek_similarity) }
    ];
    const top = similarities.reduce((a, b) => a.value > b.value ? a : b);
    return `${top.model} (${formatSimilarity(top.value)})`;
} 