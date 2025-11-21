import pymysql as mysql
import configparser
import csv

def readCredentials(configFile):
    #getting the credentials
    config = configparser.ConfigParser()

    try:
        config.read_file(open(configFile))
        dbConfig = {
            "host": config['csc']['dbhost'],
            "user": config['csc']['dbuser'],
            "password": config['csc']['dbpw'],
        }
        return dbConfig
    except FileNotFoundError as e:
        print(f'Error: {e} was not found.')
        raise

#connects the user to the database
def connectDB(dbName, configFile):
    #calls the credentials function
    dbConfig = readCredentials(configFile)

    # Open database connection
    dbConn = mysql.connect(host=dbConfig["host"],
                             user=dbConfig["user"],
                             passwd=dbConfig["password"],
                             db=dbName,
                             use_unicode=True,
                             charset='utf8mb4',
                             autocommit=True)

    print('Connected to database.')
    return dbConn

#Closing the database
def closeDB(dbConn):
    print('Closing database connection.')
    dbConn.close()

#processing the data
def processCSV(dbCon, csvFile):
    # batchSize = 500
    with open(csvFile) as ChessFile:
        chessFileReader = csv.DictReader(ChessFile)
        # batchCounter = 1
        gameList = []
        for gameDict in chessFileReader:
            gameList.append(processRow(dbCon, gameDict))
            # if batchCounter == batchSize:
            #     saveChessGame(dbCon, gameList)
            #     gameList = []
            #     batchCounter = 1
            # else:
            #     batchCounter += 1
    # saveChessGame(dbCon, gameList)

def processRow(dbCon, gameDict):
    print(f'Row Keys: {list(gameDict.keys())}')
    gameDict = cleanDict(gameDict)
    openingId = getOpeningDimensions(dbCon, (gameDict['opening_eco'], gameDict['opening_name'], gameDict['opening_ply']))
    whiteId = getWhiteDimension(dbCon, gameDict['white_rating'])
    blackId = getBlackDimension(dbCon, gameDict['black_rating'])
    statusId = getStatusDimensions(dbCon, (gameDict['winner'], gameDict['victory_status'], gameDict['turns']))
    timeId = getTimeDimensions(dbCon, (gameDict['created_at'], gameDict['last_move_at'], gameDict['increment_code']))
    gameId = getGameDimensions(dbCon, (gameDict['id'], gameDict['rated'], statusId, timeId))
    playerId = getPlayerSection(dbCon, (gameDict['white_id'], gameDict['black_id'], gameId))
    moveId = getMoveDimension(dbCon, (gameDict['moves'], openingId, playerId))
    return (
        openingId, whiteId, blackId, statusId, timeId, playerId, moveId, gameId
    )

#creates a dictinary that replaces all null values with None
def cleanDict(initalDict):
    cleanedDict = {}
    for key, value in initalDict.items():
        if value == "":
            cleanedDict[key] = None
        else:
            cleanedDict[key] = value
    return cleanedDict

#saves all the information, but for now will only save the information of the first item
# def saveChessGame(dbCon, batchSQLList):
#     print("saving the chess data....")
#     insertItems = "insert into Chess_Game(Opening_id, White_Player_id, Black_Player_id, Status_id, Time_id, Player_id, Move_id, Game_Primary_ID) values (%s, %s, %s, %s, %s, %s, %s, %s);"
#     cursor = dbCon.cursor()
#     cursor.executemany(insertItems, batchSQLList)
#     dbCon.commit()
#     cursor.close()
#     print("data saved")

#checking if the database has the value
def getDimensionId(dbCon, dimensionSQL, dimensionLookupValue, DimensionValueColum):
    print(f'Running: {dimensionSQL}')
    print(f'Lookup Value: {dimensionLookupValue}')
    cursor = dbCon.cursor(mysql.cursors.DictCursor)
    cursor.execute(dimensionSQL, dimensionLookupValue)
    result = cursor.fetchone()
    cursor.close()
    if result is None:
        return None
    return result[DimensionValueColum]

#inserting the value
def insertDimension(dbCon, insertSQL, insertValue):
    print(f'Running: {insertSQL}')
    print(f'Insert Value: {insertValue}')
    cursor = dbCon.cursor()
    cursor.execute(insertSQL, insertValue)
    #getting the value of the auto ky
    cursor.execute("SELECT LAST_INSERT_ID();")
    #getting the result
    auto_key = cursor.fetchone()[0]
    cursor.close()
    return auto_key

def mappedDimension(dbCon, dimensionLookUpSQL, dimensionInsertSQL, dimensionLookupValue, dimensionValueColum):
    if dimensionLookUpSQL is None:
        return None
    dimensionId = getDimensionId(dbCon, dimensionLookUpSQL, dimensionLookupValue, dimensionValueColum)
    if dimensionId is None:
        dimensionId = insertDimension(dbCon, dimensionInsertSQL, dimensionLookupValue)
    return dimensionId

#getting the opening section
def getOpeningDimensions(dbCon, openingVaule):
    print('Getting Opening Dimensions')
    return mappedDimension(dbCon, "select Chess_Opening_id from Chess_Opening where Eco = %s and Name = %s and Opening_Play =  %s;", "insert into Chess_Opening (Eco, Name, Opening_Play) values (%s, %s, %s);", openingVaule, "Chess_Opening_id")


#getting the white section
def getWhiteDimension(dbCon, whiteVaule):
    print('Getting White Dimensions')
    return mappedDimension(dbCon, "select White_Player_id from Chess_White where Rating = %s;", "insert into Chess_White (Rating) values (%s);", whiteVaule, "White_Player_id")

#getting the black section
def getBlackDimension(dbCon, blackVaule):
    print('Getting Black Dimensions')
    return mappedDimension(dbCon, "select Black_Player_id from Chess_Black where Rating = %s;", "Insert into Chess_Black (Rating) values (%s);", blackVaule, "Black_Player_id")

#getting the player section
def getPlayerSection(dbCon, playerVaule):
    print('Getting Player Section')
    return mappedDimension(dbCon, "select Player_id from Chess_Player where White_player = %s and Black_player = %s and Game_Primary_ID = %s;", "insert into Chess_Player(White_player, Black_player, Game_Primary_ID) values (%s, %s, %s);", playerVaule, "Player_Id")

#getting the moves sections
def getMoveDimension(dbCon, moveVaule):
    print('Getting Move Dimensions')
    return mappedDimension(dbCon, "select Moves_id from Chess_Moves where Moves = %s and Chess_Opening_id = %s and Player_id = %s;", "insert into Chess_Moves(Moves, Chess_Opening_id, Player_id) values (%s, %s, %s);", moveVaule, "Moves_Id")

#getting the status section
def getStatusDimensions(dbCon, statusVaule):
    print('Getting Status Dimensions')
    return mappedDimension(dbCon, "select Status_id from Chess_Winning_Stats where Winning_player = %s and Victory_results = %s and Number_of_turns = %s;", "insert into Chess_Winning_Stats (Winning_player, Victory_results, Number_of_turns) values (%s, %s, %s);", statusVaule, "Status_id")

#getting the time section
def getTimeDimensions(dbCon, timeVaule):
    print('Getting Time Dimensions')
    return mappedDimension(dbCon, "select Time_id from Chess_Time where Start_time = %s and End_time = %s and Time_incrument = %s;", "insert into Chess_Time (Start_time, End_time, Time_incrument) values (%s, %s, %s);", timeVaule, "Time_id")

def getGameDimensions(dbCon, gameVaule):
    print('Getting Game Dimensions')
    return mappedDimension(dbCon, "select Game_Primary_ID from Chess_Game where Game_id = %s and Rated = %s and Status_id = %s and Time_id = %s", "insert into Chess_Game (Game_id, Rated, Status_id, Time_id) values (%s, %s, %s, %s);", gameVaule, "Game_Primary_ID")

def main():
    try:
    #     reading the credentials first, using the database we are going to use
        dbCon = connectDB('ddiaz11', 'credentuals.txt')
        data = "games.csv"
        #should insert something into the database
        try:
            # 2 Process the File
            processCSV(dbCon, data)

        #it did not and cry and yell at computer
        except Exception as e:
            print(e)
        finally:
            closeDB(dbCon)
    except Exception as e:
        print(e)


if __name__ == '__main__':
    main()