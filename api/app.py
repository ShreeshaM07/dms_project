import pandas as pd
from flask import Flask, request, jsonify
import datetime



app = Flask(__name__)

@app.route('/maketournament', methods=['POST'])
def makeTournament():
    try:
        data = request.get_json()
        numberOfTeams = data.get('numberOfTeams')
        teamNames = data.get('teamNames')
        n_2 = int(numberOfTeams)
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
            new_round.append(teamNames[roundt1[i]-1] + " vs " + teamNames[roundt2[i]-1])
        
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
                new_round2.append(teamNames[roundt1[j]-1] + " vs " + teamNames[roundt2[j]-1])
            df["round" + str(i)] = new_round2
        print(df)
        result = df.to_dict()
        
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    

@app.route('/scheduletournament', methods=['POST'])
def create_dated_schedule():
    try:
        data = request.get_json()
        jsonData = data.get('jsonData')
        df = pd.DataFrame.from_dict(jsonData)
        
        # Process jsonData to create a 2D list with matches of specific rounds
        column_lists = [df[column].tolist() for column in df.columns]
        
        # Combine the lists into a 2D list (transpose the list of lists)
        dated_schedule = list(column_lists)
        # print(dated_schedule)
        # Calculate the date of the Saturday four weeks from today 
        today = datetime.date.today()
        two_weeks_later = today + datetime.timedelta(days=(26 - today.weekday()))
        
        # Iterate through the 2D list and add dates to each round of matches
        for i in range(len(dated_schedule)):
            # Format the date as 'YYYY-MM-DD'
            formatted_date = two_weeks_later.strftime('%d-%m-%Y')
            for j in range(len(dated_schedule[i])//2):
            
                # Add the formatted date to the beginning of each round of matches
                dated_schedule[i][j] =  formatted_date + '\n' + dated_schedule[i][j]
            for j in range(len(dated_schedule[i])//2,len(dated_schedule[i])):
                sunday_date=two_weeks_later+datetime.timedelta(days=1)
                dated_schedule[i][j] =  sunday_date.strftime('%d-%m-%Y') + '\n' + dated_schedule[i][j]
                #print(dated_schedule[i][j])
            # Increment the date by 7 days for the next round of matches
            two_weeks_later += datetime.timedelta(days=7)
        print(dated_schedule)
        # Return the updated 2D list as a response
        return jsonify({'dated_schedule': dated_schedule})
    except Exception as e:
        return jsonify({'error': str(e)}), 400


@app.route('/homeawayscheduling', methods=['POST'])
def HomeAwaySchedule():
    try:
        data = request.get_json()
        numberOfTeams = data.get('numberOfTeams')
        teamNames = data.get('teamNames')
        n_2 = int(numberOfTeams)
        n = n_2 // 2
        roundt1 = []
        roundt2 = []
        roundt1.append(n_2)
        roundt2.append(1)
        
        for i in range(2, n + 1):
            roundt1.append(n_2 - i + 1)
            roundt2.append(i)

        new_round=[]
        for i in range(len(roundt1)):
            new_round.append(teamNames[roundt1[i]-1] + " vs " + teamNames[roundt2[i]-1])

        df = pd.DataFrame()
        df["round1"] = new_round
        
        for i in range(2,n_2):
            roundt1[0],roundt2[0]=roundt2[0],roundt1[0]
            if(i%2==0):
                roundt1[0]+=n
                if(roundt1[0]>n_2-1):
                    roundt1[0]-=n_2-1
            else:
                roundt2[0]+=n
                if(roundt2[0]>n_2-1):
                    roundt2[0]-=n_2-1
                
                
            for j in range(1,len(roundt1)):
                if roundt1[j] != n_2 and roundt2[j] != n_2:
                    roundt1[j] += n
                    if roundt1[j] > n_2 - 1:
                        roundt1[j] -= (n_2 - 1)
                    roundt2[j] += n
                    if roundt2[j] > n_2 - 1:
                        roundt2[j] -= (n_2 - 1)
                elif roundt1[j] == n_2:
                    roundt2[j] += n
                elif roundt2[j] == n_2:
                    roundt1[j] += n

            new_round2 = []
            for j in range(len(roundt1)):
                new_round2.append(teamNames[roundt1[j]-1] + " vs " + teamNames[roundt2[j]-1])
            df["round" + str(i)] = new_round2

        roundt1=[]
        roundt2=[]
        roundt1.append(1)
        roundt2.append(n_2)

        for i in range(2, n + 1):
            roundt1.append(i)
            roundt2.append(n_2 - i + 1)

        new_round=[]
        for i in range(len(roundt1)):
            new_round.append(teamNames[roundt1[i]-1] + " vs " + teamNames[roundt2[i]-1])

        # df = pd.DataFrame()
        df["round"+str(n_2)] = new_round
        for i in range(n_2+1,2*n_2-1):
        #     print('round',i)
            roundt1[0],roundt2[0]=roundt2[0],roundt1[0]
            if(i%2==0):
                roundt1[0]+=n
                if(roundt1[0]>n_2-1):
                    roundt1[0]-=n_2-1
            else:
                roundt2[0]+=n
                if(roundt2[0]>n_2-1):
                    roundt2[0]-=n_2-1
                
                
            for j in range(1,len(roundt1)):
                if roundt1[j] != n_2 and roundt2[j] != n_2:
                    roundt1[j] += n
                    if roundt1[j] > n_2 - 1:
                        roundt1[j] -= (n_2 - 1)
                    roundt2[j] += n
                    if roundt2[j] > n_2 - 1:
                        roundt2[j] -= (n_2 - 1)
                elif roundt1[j] == n_2:
                    roundt2[j] += n
                elif roundt2[j] == n_2:
                    roundt1[j] += n
        #     print('roundt1:',roundt1)
        #     print('roundt2:',roundt2)
            new_round2 = []
            for j in range(len(roundt1)):
                new_round2.append(teamNames[roundt1[j]-1] + " vs " + teamNames[roundt2[j]-1])
        #     print(new_round2)
            df["round" + str(i)] = new_round2



        print(df)
        result = df.to_dict()
        
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    


if __name__ == '__main__':
    app.run(host='localhost', port=5000)
