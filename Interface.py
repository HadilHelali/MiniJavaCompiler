import streamlit as st
from io import StringIO

from utils import *

st.title('Mini Java Compiler')
tab1, tab2 = st.tabs(["Write your Script", "Upload Your Script"])
col1 , col2 = st.columns(2)


with tab1:
     txt = st.text_area('Script to be compiled',placeholder='Enter your script here ...' , height=400)

with tab2 : 
    uploaded_file = st.file_uploader("Upload the script to be compiled")
    if uploaded_file is not None:
        stringio = StringIO(uploaded_file.getvalue().decode("utf-8"))
        txt = stringio.read()
        st.code(txt, language="None", line_numbers=False)
          
with col1 : 
    btn = st.button('Compile')
with col2 : 
    btn2 = st.button('reset')

if btn : 
    write_file(txt,"Compiler/Script.txt")
    output = execute_command( "Compiler/Analyseur_synx.exe" , "Compiler/Script.txt" , "Compiler/Output.txt" )
    st.subheader("Output")
    if output.isspace() or not any(output.splitlines()):
        st.success('Your script does not contain any errors', icon="✅")
    else :
        st.error(output, icon="🚨")

if btn2 :
    remove_files()
    txt = ""
