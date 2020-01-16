# README
这个此项目为上海交通大学生命科学技术学院CCMBI实验室，热力学积分(Thermodynamic integral)结合自由能计算的使用说明
## 热力学积分的原理
## 注意：
- 此项目主要针对某一过程
- 此项目主要针对在水相环境下的过程，对于真空条件下的过程，清参考……
## Environment Needed
## Install
```shell
/bin/bash setup.sh
```
## 文件关系拓扑
## 使用方法
### 1. 制作拓扑文件
#### Introduction
由于热力学积分需要知道初始状态V0与结束状态V1，即需要知道两个状态的分子结构。同时需要注意：
1. **两个状态如果有原子变化（种类、数目），则其中除了变化的原子，其余原子的坐标应该足够接近**
2. **在经过第二步`parmed`之后，体系需要呈现电中性，即tleap有可能电荷不为中性**

本项目使用Amber中的pmemd进行分子动力学模拟，其需要在一个拓扑文件(prmtop/parm7 file)中同时存在两个状态的分子结构，于是需要一步特殊的tleap。
```
# source the leaprc that you need
source leaprc.protein.ff15ipq
source leaprc.water.tip3p
source leaprc.gaff
loadAmberParams frcmod.ionsjc_tip3p

# load the force field which amber doesn't process

# load the coordinates and create the systems
m1 = loadpdb $basedir/your_v0.pdb
m2 = loadpdb $basedir/your_v1.pdb

complex = combine {m1 m2}
charge complex
set default nocenter on

# create complex in solution
addions complex Na+ 14
solvateoct complex TIP3PBOX 8
savepdb complex complex.pdb
saveamberparm complex complex.parm7 complex.rst7

quit
```
此文件为leap.in文件中，你可以在tmpl文件夹中找到此文件。
#### Progam Usage
The first step of ti_tleap.sh is about the `tleap`.
```shell
$ ti_tleap.sh
```
if you run the command, it will print:
```
This is the first step of IT:tleap
Do you want to use the leap.in file that has already existed[y/n]?  
```
if your answer is 'yes(y)', you need to make sure that there is a leap.in file in your workspace folder. 


Otherwise, if your answer is 'no(n)', the progam will copy the leap.in template to the workspace folder and run the vim to help you to edit it by hand.

Whatever ways you selected, you should guarantee that the leap.in file contains the force field file by yourself. And you need to make sure the prmtop/parm7 file is called complex.parm7 and the rst/inpcrd file is called complex.rst7.

### 2. 准备提交任务
#### Introduction
我们都知道，原子数目越多，分子动力学模拟所需的时间就越长，于是我们通过`parmed`工具对相同部分的结构进行叠合，仅变化部分的原子保留两个结构。

对于此过程而言，我们需要知道变化部分分布在V0状态和V1状态的原子，而且tleap过后原子编号可能会有稍许的改变，于是需要手动检测tleap后的结果文件并从中得到这两个状态的原子编号。而`parmed`需要读取这些编号。

`parmed`之后进行提交的文本文件的构建。

#### Progam Usage
The file ti_parmed.sh is for the second step `parmed`.
```shell
$ ti_parmed.sh
```
The program will print:
```
This is the second step of TI: parmed and get prepared for submission
Please input the mask of T0:
Please input the mask of T1:
Please input the mask of S0:
Please input the mask of S1:
```
And you can follow the prompts. With all the mask inputed already, the program will run the `parmed`. You need to be noticed that the `parmed` is a little time costing, and please to be patient. 

After the parmed step, the program will create the Submit.sh file and template input file for the pmemd at the *free_energy* folder. At the step you need to input the *distance* of every step of the ti (recommend 0.05) and the *simulation time* of every step (recommend 600ps). 
### 3. 提交任务
You can `qsub Submit.sh` if you have pbs system. Or you can change way of submitting the file to adopt your system. And try to use GPU with `pmemd.cuda` or CPU with `pmemd.MPI`. And you need to know that `pmemd.cuda` can't run the minimize with thermodynamic integral.
And the `pmemd.cuda` will break down sometimes, but the `pmemd.MPI` won't do that. So the program was designed to run `pmemd.MPI` if the `pmemd.cuda` can't do the job.

### 4. 获得结果

The python3 file ti_analysis.py is to analysis the result of thermodynamic integral. Please run the python script at the folder where you submitted the Submit.sh. 

The python script will create a file called *dVdl.dat* which contains the details of every step. At last, it will print the **delta-G** of the process. And the file called *dVdl.csv*  contains the simaller things. And the *dVdl.png* is the plot of the thermodynamic integral


## EXAMPLE
文件夹example中包含一个Thermodynamic integral的例子：将脱水酶Gphf中的leu45突变成Pro45的例子，野生型为 Gphf.pdb，突变体为 GphfP.pdb。而其中 leap.in为tleap所需要的文件。
