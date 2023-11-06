import pandas as pd
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/maketournament', methods=['POST'])
def makeTournament():
    try:
        data = request.form['number']
        n_2 = int(data)
        n = n_2 // 2
        roundt1 = []
        roundt2 = []
        roundt1.append(n_2)
        roundt2.append(1)
        
        for i in range(2, n + 1):
            roundt1.append(n_2 - i + 1)
            roundt2.append(i)

        new_round = []
        for i in range(len(roundt1)):
            new_round.append(str(roundt1[i]) + " vs " + str(roundt2[i]))
        
        df = pd.DataFrame()
        df["round1"] = new_round
        
        for i in range(2, n_2):
            for j in range(len(roundt1)):
                if roundt1[j] != n_2 and roundt2[j] != n_2:
                    roundt1[j] += 1
                    if roundt1[j] > n_2 - 1:
                        roundt1[j] -= (n_2 - 1)
                    roundt2[j] += 1
                    if roundt2[j] > n_2 - 1:
                        roundt2[j] -= (n_2 - 1)
                elif roundt1[j] == n_2:
                    roundt2[j] += 1
                elif roundt2[j] == n_2:
                    roundt1[j] += 1
            new_round2 = []
            for j in range(len(roundt1)):
                new_round2.append(str(roundt1[j]) + " vs " + str(roundt2[j]))
            df["round" + str(i)] = new_round2
        
        result = df.to_dict()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='localhost', port=5000)
