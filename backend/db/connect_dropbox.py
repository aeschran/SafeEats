



# importing necessary libraries 
import dropbox 
  
# Token Generated from dropbox 
TOKEN = "legacy_token"
  
# Establish connection 
def connect_to_dropbox(): 
    
    try: 
        dbx = dropbox.Dropbox(TOKEN) 
        print('Connected to Dropbox successfully') 
      
    except Exception as e: 
        print(str(e)) 
      
    return dbx 
  
# explicit function to list files 
def list_files_in_folder(): 
    
    # here dbx is an object which is obtained 
    # by connecting to dropbox via token 
    dbx = connect_to_dropbox() 
      
    try: 
        folder_path = "/folder_path"
  
        # dbx object contains all functions that  
        # are required to perform actions with dropbox 
        files = dbx.files_list_folder(folder_path).entries 
        print("------------Listing Files in Folder------------ ") 
          
        for file in files: 
              
            # listing 
            print(file.name) 
              
    except Exception as e: 
        print(str(e)) 
  
class TransferData:
    def __init__(self, access_token):
        self.access_token = access_token

    def upload_file(self, file_from, file_to):
        """upload a file to Dropbox using API v2
        """
        dbx = dropbox.Dropbox(self.access_token)

        with open(file_from, 'rb') as f:
            dbx.files_upload(f.read(), file_to)

def main():
    access_token = '******'
    transferData = TransferData(access_token)

    file_from = 'test.txt'
    file_to = '/test_dropbox/test.txt'  # The full path to upload the file to, including the file name

    # API v2
    transferData.upload_file(file_from, file_to)

if __name__ == '__main__':
    main()
    
dbx = connect_to_dropbox() 
list_files_in_folder()