
# Project Goal 


The project goal is to retrieve the activity the time activiy of my mac per appllication and load it in R2 the data lake of Cloudflaire using python 


# Stack 


<p align="center">
  <a href="https://go-skill-icons.vercel.app/">
    <img src="https://go-skill-icons.vercel.app/api/icons?i=py,pandas,sqlite,cloudflare,bash,git,github" />
  </a>
</p>





# Architecture Schema 


![Copie de Schema play-gcp-bq](https://github.com/user-attachments/assets/90f9256f-7ecc-4efc-9764-dc0e74c8247e)



# Technical explanation 


The program is contain on main.py with 3 functions that i will comment just below 



## test_before_retrieve


```py
def test_before_retrieve():
    system_os = platform.system()

    if system_os == 'Darwin':
        print(" It's the good operating system")
    else:
        raise ValueError("The operating system need to be a mac os")


    user_dir = os.path.expanduser('~')


    pattern = f"{user_dir}/Library/Application Support/Knowledge/knowledgeC.db"
    matches = glob.glob(pattern)

    if len(matches) != 1:
        raise ValueError("The database file was not found")
    else:
        print("The database file was found")

    return matches[0]

```


This function have to main goal to verify if the computer is a mac (mandatory for this project) and then check if the db is accessible or not if one of the condition is wrong the program stop and raise an error else it's printing in the log file that i have in my local repo. Also, the repo get the path to the db (we do a the expand user to get the beginning example 'Users/username') the function return the path to the sqlite db.




### retrieve_data


```py

def retrieve_data():


    db_path = test_before_retrieve()

    print(f"Trying to connect to database at: {db_path}")



    try:
        conn = sqlite3.connect(db_path)
        print("Connected to database")

        query = "SELECT * FROM ZOBJECT"

        df = pd.read_sql_query(query, conn)

        # Get the current date
        current_date = datetime.datetime.now().strftime("%d_%m_%Y")

        # Create the file name pattern
        file_name_pattern = f"data_mac_{current_date}"

        # Create the file path
        csv_file_path = os.path.join('files', f"{file_name_pattern}.csv")


        df.to_csv(csv_file_path, index=False)

        conn.close()
    
    except sqlite3.OperationalError as e:
        print(f"Error connecting to database: {e}")
        print(f"Database path: {os.path.abspath(db_path)}")
        print(f"Database path: {db_path}")
        print(f"Current user: {os.getuid()}")
        raise ValueError(f"Please check the database connection: {e}. Check the privilege for the IDE and for the terminal.")

    return df



```


The function **Retrieve_data**, first retrieve all the line and columns in the knowledgeDB then load it in a pandas dataframe and finaly save in the local respository *files* as a csv with this pattern *data_mac_DD_MM_YYYY*



### load_data_to_r2


```py
r2_endpoint = os.getenv('R2_ENDPOINT')
access_key = os.getenv('R2_ACCESS_KEY')
secret_key = os.getenv('R2_SECRET_KEY')

print(f"R2 endpoint: {r2_endpoint}")

def load_data_to_r2(r2_endpoint, access_key, secret_key):
    # Création du client S3 compatible avec R2
    s3 = boto3.client('s3',
                      endpoint_url=r2_endpoint,
                      aws_access_key_id=access_key,
                      aws_secret_access_key=secret_key,
                      config=Config(signature_version='s3v4'))

    # Télécharger le fichier CSV dans un bucket R2

    current_date = datetime.datetime.now().strftime("%d_%m_%Y")


    file_name_pattern = f"data_mac_{current_date}"
    
    csv_file_path = os.path.join('files', f"{file_name_pattern}.csv")
    
    bucket_name = 'usertime'
    object_key = f"{file_name_pattern}.csv"

    s3.upload_file(csv_file_path, bucket_name, object_key)
    print(f"DataFrame uploaded to R2 bucket {bucket_name} with key {object_key}")

load_data_to_r2(r2_endpoint, access_key, secret_key)

```


The last function just retrieve in the *files* local repository the files of the day and load it into the R2 bucket

