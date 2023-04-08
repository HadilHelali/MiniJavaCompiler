import os
from subprocess import check_call, STDOUT

def write_file(content,filename):
    f = open(filename,"w")
    f.write(content)
    f.close()

def read_file(filename):
    f = open(filename,"r")
    content = f.read()
    return content

def remove_files():
    dir_path = "Compiler/"
    files_to_remove = ["Script.txt", "Output.txt"]
    for file in files_to_remove:
        file_path = os.path.join(dir_path, file)
        os.remove(file_path)

def remove_empty_lines(filename):

    with open(filename, 'r') as file:
        lines = file.readlines()
    
    non_empty_lines = [line for line in lines if line.strip() != '']

    with open(filename, 'w') as file:
        file.writelines(non_empty_lines)

def removeStrings(filename,string):
    with open(filename, 'r') as file:
        contents = file.read()

    modified_contents = contents.replace(string, '')

    with open(filename, 'w') as file:
        file.write(modified_contents)

def execute_command(command , inputfile , outputfile ):
    with open(inputfile) as file, open(outputfile, 'w') as outfile:
        check_call([command],stdin=file, stdout=outfile, stderr=STDOUT)

    remove_empty_lines(outputfile)
    removeStrings(outputfile,'COMMENT BLOCK')

    return read_file(outputfile)

