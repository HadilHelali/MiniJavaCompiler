import streamlit as st
from io import StringIO
import pandas as pd
import numpy as np

from utils import *

st.title('Mini Java Compiler')
tab1, tab2 = st.tabs(["Write your Script", "Upload Your Script"])
col1 , col2 = st.columns(2)


with tab1:
     txt = st.text_area('Script to be compiled',placeholder='Enter your script here ...' ,
                        height=400)

with tab2 : 
    uploaded_file = st.file_uploader("Upload the script to be compiled")
    if uploaded_file is not None:
        stringio = StringIO(uploaded_file.getvalue().decode("utf-8"))
        txt = stringio.read()
        st.code(txt, language="None", line_numbers=True)
          
with col1 : 
    btn = st.button('Compile')
with col2 : 
    btn2 = st.button('reset')

if btn : 
    write_file(txt,"Compiler/Script.txt")
    output , error = execute_command( "Compiler_Files/Compilateur.exe" , "Compiler/Script.txt" , "Compiler/Output.txt" )
    st.subheader("Output")

    if error.isspace() or not any(error.splitlines()):
        st.success('Your script does not contain any errors', icon="✅")
    else :
        lines = error.splitlines()
        for line in lines:
            if "warning" in line:
                st.warning(line, icon="⚠️")
            else:
                st.error(line, icon="🚨")
    st.subheader("Langage machine généré")
    st.code(output, language="None", line_numbers=False)

if btn2 :
    remove_files()
    txt = ""
