import json
import os
from pathlib import Path
import graphify
from graphify.extract import extract
from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from graphify.export import to_json, to_html

def update_graph():
    os.makedirs('graphify-out', exist_ok=True)
    root = Path('.')
    
    code_files = sorted([p for p in root.glob('lib/**/*.dart')] + [p for p in root.glob('test/**/*.dart')])
    total_words = 0
    for f in code_files:
        try:
            total_words += len(f.read_text(encoding='utf-8', errors='ignore').split())
        except Exception:
            pass

    print(f'Graphify: Indexing {len(code_files)} Dart files (~{total_words:,} words)...')

    result = extract(code_files, cache_root=root)
    Path('graphify-out/.graphify_ast.json').write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding='utf-8')
    Path('graphify-out/.graphify_extract.json').write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding='utf-8')

    G = build_from_json(result, root='.', directed=False)
    print(f'Graph built: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges')

    communities = cluster(G)
    cohesion = score_all(G, communities)
    tokens = {'input': result.get('input_tokens', 0), 'output': result.get('output_tokens', 0)}
    gods = god_nodes(G)
    surprises = surprising_connections(G, communities)
    
    # Meaningful community labels based on top nodes
    labels = {}
    for cid, members in communities.items():
        sub_gods = [n for n in gods if n in members]
        if sub_gods:
            labels[cid] = f"{sub_gods[0].split('/')[-1]} Community"
        else:
            first = list(members)[0].split('/')[-1] if members else f"Module {cid}"
            labels[cid] = f"{first} Community"

    questions = suggest_questions(G, communities, labels)

    to_json(G, communities, 'graphify-out/graph.json')
    try:
        to_html(G, communities, 'graphify-out/graph.html')
    except Exception as e:
        print(f"Notice (HTML export): {e}")

    detect_summary = {
        'total_files': len(code_files),
        'total_words': total_words,
        'files': {'code': [str(f) for f in code_files]}
    }
    
    report = generate(G, communities, cohesion, labels, gods, surprises, detect_summary, tokens, '.', suggested_questions=questions)
    Path('graphify-out/GRAPH_REPORT.md').write_text(report, encoding='utf-8')
    print('✅ Graphify: graphify-out/ (graph.json, graph.html, GRAPH_REPORT.md) updated successfully!')

if __name__ == '__main__':
    update_graph()
