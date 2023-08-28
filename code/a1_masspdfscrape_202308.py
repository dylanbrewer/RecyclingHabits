# Authors: Dylan Brewer and Samantha Cameron
# Title: Habit and skill retention in recycling
# Version: August 2023
# imports and clean massachusetts pdf data

# Load packages
import tabula
import pandas as pd
from pathlib import Path

# Set to the pdf in the raw data folder on your computer
file_path = r"C:\Users\brewe\Dropbox\PaperIdeas\RecyclingHabits\data\raw\munirate.pdf"
# Set to the desired csv in the final data folder on your computer
path = Path(r"C:\Users\brewe\Dropbox\PaperIdeas\RecyclingHabits\data\final\munirate_clean.csv")

fc = 28.346
#[top,left,bottom,width]
##### 1,1 ########
title_11_box = [5,1.3,5.42,6]
for i in range(0,len(title_11_box)):
    title_11_box[i] *= fc

table_11_box = [5.5,2.8,11.5,5.9]
for i in range(0,len(table_11_box)):
    table_11_box[i] *= fc

title_11 = tabula.read_pdf(file_path, area = [title_11_box],output_format= "dataframe",pandas_options = {'header':None}, pages = '1-39')
table_11 = tabula.read_pdf(file_path, area = [table_11_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_11 = table_11[0]
df_11.columns = ["Year", "Recycling Rate"]

muni_11 = title_11[0]
muni_list = []
for i in range(len(muni_11)):
    muni_list.append(muni_11.iloc[i,0])

df_11['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,469):
    if i in index_list:
        df_11.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_11.loc[i,'Municipality'] = muni_list[m]

#[top,left,bottom,width]
##### 1,2 ########
title_12_box = [5,6.8,5.42,12]
for i in range(0,len(title_12_box)):
    title_12_box[i] *= fc

table_12_box = [5.5,8.6,11.5,12]
for i in range(0,len(table_12_box)):
    table_12_box[i] *= fc

title_12 = tabula.read_pdf(file_path, area = [title_12_box],output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')
table_12 = tabula.read_pdf(file_path, area = [table_12_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_12 = table_12[0]
df_12.columns = ["Year", "Recycling Rate"]

muni_12 = title_12[0]
muni_list = []
for i in range(len(muni_12)):
    muni_list.append(muni_12.iloc[i,0])

df_12['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,468):
    if i in index_list:
        df_12.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_12.loc[i,'Municipality'] = muni_list[m]

#[top,left,bottom,width]
##### 1,3 ########
title_13_box = [5,12.7,5.42,20]
for i in range(0,len(title_13_box)):
    title_13_box[i] *= fc

table_13_box = [5.5,14.4,11.5,17.7]
for i in range(0,len(table_13_box)):
    table_13_box[i] *= fc

title_13 = tabula.read_pdf(file_path, area = [title_13_box],output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')
table_13 = tabula.read_pdf(file_path, area = [table_13_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_13 = table_13[0]
df_13.columns = ["Year", "Recycling Rate"]

muni_13 = title_13[0]
muni_list = []
for i in range(len(muni_13)):
    muni_list.append(muni_13.iloc[i,0])

df_13['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,468):
    if i in index_list:
        df_13.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_13.loc[i,'Municipality'] = muni_list[m]

#[top,left,bottom,width]
##### 2,1 ########
title_21_box = [11.4,1.3,12,8]
for i in range(0,len(title_21_box)):
    title_21_box[i] *= fc

table_21_box = [12,2.8,18,5.9]
for i in range(0,len(table_21_box)):
    table_21_box[i] *= fc

title_21 = tabula.read_pdf(file_path, area = [title_21_box],output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')
table_21 = tabula.read_pdf(file_path, area = [table_21_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_21 = table_21[0]
df_21.columns = ["Year", "Recycling Rate"]

muni_21 = title_21[0]
muni_list = []
for i in range(len(muni_21)):
    muni_list.append(muni_21.iloc[i,0])

df_21['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,468):
    if i in index_list:
        df_21.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_21.loc[i,'Municipality'] = muni_list[m]


#[top,left,bottom,width]
##### 2,2 ########
title_22_box = [11.4,6.8,12,10]
for i in range(0,len(title_22_box)):
    title_22_box[i] *= fc

table_22_box = [12,8.6,18,12]
for i in range(0,len(table_22_box)):
    table_22_box[i] *= fc

title_22 = tabula.read_pdf(file_path, area = [title_22_box],output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')
table_22 = tabula.read_pdf(file_path, area = [table_22_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_22 = table_22[0]
df_22.columns = ["Year", "Recycling Rate"]

muni_22 = title_22[0]
muni_list = []
for i in range(len(muni_22)):
    muni_list.append(muni_22.iloc[i,0])

df_22['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,468):
    if i in index_list:
        df_22.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_22.loc[i,'Municipality'] = muni_list[m]

#[top,left,bottom,width]
##### 2,3 ########
title_23_box = [11.4,12.7,12,18]
for i in range(0,len(title_23_box)):
    title_23_box[i] *= fc

table_23_box = [12,14.4,18,17.7]
for i in range(0,len(table_23_box)):
    table_23_box[i] *= fc

title_23 = tabula.read_pdf(file_path, area = [title_23_box],output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')
table_23 = tabula.read_pdf(file_path, area = [table_23_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_23 = table_23[0]
df_23.columns = ["Year", "Recycling Rate"]

muni_23 = title_23[0]
muni_list = []
for i in range(len(muni_23)):
    muni_list.append(muni_23.iloc[i,0])

df_23['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,468):
    if i in index_list:
        df_23.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_23.loc[i,'Municipality'] = muni_list[m]
#[top,left,bottom,width]
##### 3,1 ########
title_31_box = [17.9,1.3,18.4,6]
for i in range(0,len(title_31_box)):
    title_31_box[i] *= fc

table_31_box = [18.5,2.8,24.5,5.9]
for i in range(0,len(table_31_box)):
    table_31_box[i] *= fc

title_31 = tabula.read_pdf(file_path, area = [title_31_box],output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')
table_31 = tabula.read_pdf(file_path, area = [table_31_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_31 = table_31[0]
df_31.columns = ["Year", "Recycling Rate"]

muni_31 = title_31[0]
muni_list = []
for i in range(len(muni_31)):
    muni_list.append(muni_31.iloc[i,0])

df_31['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,468):
    if i in index_list:
        df_31.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_31.loc[i,'Municipality'] = muni_list[m]

#[top,left,bottom,width]
##### 3,2 ########
title_32_box = [17.9,6.8,18.4,11]
for i in range(0,len(title_32_box)):
    title_32_box[i] *= fc

table_32_box = [18.5,8.6,24.5,12]
for i in range(0,len(table_32_box)):
    table_32_box[i] *= fc

title_32 = tabula.read_pdf(file_path, area = [title_32_box],output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')
table_32 = tabula.read_pdf(file_path, area = [table_32_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_32 = table_32[0]
df_32.columns = ["Year", "Recycling Rate"]

muni_32 = title_32[0]
muni_list = []
for i in range(len(muni_32)):
    muni_list.append(muni_32.iloc[i,0])

df_32['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,468):
    if i in index_list:
        df_32.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_32.loc[i,'Municipality'] = muni_list[m]

#[top,left,bottom,width]
##### 3,3 ########
title_33_box = [17.9,12.7,18.4,18]
for i in range(0,len(title_33_box)):
    title_33_box[i] *= fc

table_33_box = [18.5,14.4,24.5,17.7]
for i in range(0,len(table_33_box)):
    table_33_box[i] *= fc

title_33 = tabula.read_pdf(file_path, area = [title_33_box],output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')
table_33 = tabula.read_pdf(file_path, area = [table_33_box], output_format= "dataframe",pandas_options = {'header':None}, pages = 'all')

df_33 = table_33[0]
df_33.columns = ["Year", "Recycling Rate"]

muni_33 = title_33[0]
muni_list = []
for i in range(len(muni_33)):
    muni_list.append(muni_33.iloc[i,0])

df_33['Municipality'] = ""

index_list = []
y=11
index_list.append(y)
for i in range (0,37):
    y +=12
    index_list.append(y)

m=0
for i in range(1,468):
    if i in index_list:
        df_33.loc[i,"Municipality"] = muni_list[m]
        m+=1
    else:
        df_33.loc[i,'Municipality'] = muni_list[m]


dfs = [df_11,df_12,df_13,df_21,df_22,df_23,df_31,df_32,df_33]
result = pd.concat(dfs, ignore_index = True)

result.loc[0,"Municipality"] = 'ABINGTON'
result.loc[468,"Municipality"] = 'DEVENS'
result.loc[469,"Municipality"] = 'ADAMS'
result.loc[937,"Municipality"] = 'AMESBURY'
result.loc[1405,"Municipality"] = 'ACTON'
result.loc[1873,"Municipality"] = 'AGAWAM'
result.loc[2341,"Municipality"] = 'AMHERST'
result.loc[2809,"Municipality"] = 'ACUSHNET'
result.loc[3277,"Municipality"] = 'ALFORD'
result.loc[3745,"Municipality"] = 'ANDOVER'

path.parent.mkdir(parents=True, exist_ok=True)
result.to_csv(path)
