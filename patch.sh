#!/bin/bash
if [ "$1" = "search" ];then
	BiNs=$(echo $PATH | sed 's/:/ /g')
	for BiN in $BiNs none
	do
        	if [ -e "$BiN/$2" ];then
        	        echo "$BiN/$2"
        	        break
	        elif [ "$BiN" = "none" ];then
                	echo  $BiN
		fi

	done
elif [ "$1" = "checkn" ];then
	echo -e "\033[41;39mCannot find program \"$2\" please install it.\n找不到应用程序 “$2”，请将其安装。\033[0m"
	exit
elif [ "$1" = "checky" ];then
	echo -e "\033[32mProgram \"$2\" has been found, the complete path is \"$($0 search $2)\".\n程序 “$2” 已找到, 其完整路径为 “$($0 search $2)”。\033[0m"
	exit
elif [ "$1" = "choice" ];then
	echo 
	read -p "input \"y\" to continue / 输入 “y” 以继续 :" num
	if [ "$num" = "y" ];then
		echo 
		$0 $2 $3
	elif [ "$num" = "Y" ];then
		echo 
		$0 $2 $3
	else
		echo -e "\nOperation cancelled by User.\n操作被用户取消。"
	fi
	exit
elif [ "$1" = "chkdir" ];then
	echo -e "\033[34m\nSearching for target patch file \"BuildServer.jar\" ......\n正在寻找目标修补文件“BuildServer.jar”......\033[0m"
	if [ -d "./BuildServer" ];then
		if [ -e "./BuildServer/BuildServer.jar" ];then
			echo -e "\033[32mFile has been found / 文件已找到\n./BuildServer/BuildServer.jar\033[0m"
			$0 $2
			exit
		else
			echo -e "Cannot find \"BuildServer.jar\" in \"BuildServer\" directory.\n无法在“BuildServer”目录下找到“BuildServer.jar”文件。"
		fi
	else
		echo -e "Cannot find \"BuildServer\" folder in current directory, please check whether the current directory where AI2 is located\n无法在当前目录下找到“BuildServer”文件夹，请检查当前目录是否为 AI2 所在目录。"
	fi
	exit
elif [ "$1" = "Step1" ];then
	echo -e "\033[34m\nChecking required program......\n检查所需的程序......\033[0m"
	if [ "$($0 search aapt)" = "none" ] ;then
		$0 checkn aapt
		exit
	else
		$0 checky aapt
	fi
	if [ "$($0 search aapt2)" = "none" ] ;then
		echo -e "Cannot find program \"aapt2\", they will make AAB installation package cannot generate. (no any effect on generate APK)\n找不到应用程序 “aapt2”，这将使得 AAB 安装包无法生成。（对生成 APK 没有影响）"
		$0 choice Step2
	else
		$0 checky aapt2
		$0 Step2
	fi
	exit
elif [ "$1" = "Step2" ];then
	if [ "$($0 search zipalign)" = "none" ] ;then
		$0 checkn zipalign
		exit
	else
		$0 checky zipalign
	fi

	echo -e "\n\033[1m\033[32mRequired program has been installed, It will into patching step now.\n所需的程序已经安装，现在将进入修补阶段。\033[0m"
	$0 choice RepackStart
	exit
elif [ "$1" = "RepackStart" ];then
	StDiR=$(pwd)
	TmPdIr=TempOfBugteas
	BuD=BuildServer
	echo -e "\033[34mCreate temp directory......\n创建临时目录......\033[0m"
	mkdir -v $TmPdIr
	cd $TmPdIr
	echo -e "\033[34m\nUnpacking \"BuildServer.jar\" file......\n正在解包 “BuildServer.jar” 文件......\033[0m"
	UnP="jar -xvf $StDiR/$BuD/BuildServer.jar"
	echo "$UnP"
	UnPsT=$($UnP)
	if [ -d "$StDiR/$TmPdIr/tools/" ];then
		echo -e "\033[32mUnpacking successful. / 解包成功。\033[0m"
	else
		echo -e "$UnPsT\n\n\033[41;39mUnpacking failed. / 解包失败。\033[0m"
		exit
	fi
	echo 
	if [ -e "$StDiR/$BuD/BuildServer.bak" ];then
		echo -e "\033[34mRemove older \"BuildServer.jar\" file......\n正在删除旧的 “BuildServer.jar” 文件......\033[0m"
		rm -v $StDiR/$BuD/BuildServer.jar
	else
		echo -e "\033[34mBackup original \"BuildServer.jar\" file......\n正在备份原有 “BuildServer.jar” 文件......\033[0m"
		mv -v $StDiR/$BuD/BuildServer.jar $StDiR/$BuD/BuildServer.bak
	fi
	echo -e "\033[34m\nReplacing files......\n正在替换文件......\033[0m"
	if [ -e "$StDiR/$TmPdIr/tools/linux/aapt" ];then
		rm -v $StDiR/$TmPdIr/tools/linux/aapt
		cp -v $(../$0 search aapt) $StDiR/$TmPdIr/tools/linux/
	fi
	if [ -e "$StDiR/$TmPdIr/tools/linux/aapt2" ];then

		if [ ! "$(../$0 search aapt2)" = "none" ] ;then
			rm -v $StDiR/$TmPdIr/tools/linux/aapt2
			cp -v $(../$0 search aapt2) $StDiR/$TmPdIr/tools/linux/
		fi
	fi
	if [ -e "$StDiR/$TmPdIr/tools/linux/zipalign" ];then
		rm -v $StDiR/$TmPdIr/tools/linux/zipalign
		cp -v $(../$0 search zipalign) $StDiR/$TmPdIr/tools/linux/
	fi
	echo -e "\033[34m\nrepacking \"BuildServer.jar\" file......\n正在重新打包 “BuildServer.jar” 文件......\033[0m"
	RpK="jar -cvf $StDiR/$BuD/BuildServer.jar *"
	echo "$RpK"
	RpKsT=$($RpK)
	if [ -e "$StDiR/$BuD/BuildServer.jar" ];then
		echo -e "\033[32mPacking successful. / 打包成功。\033[0m"
	else
		echo -e "$UpKsT\n\n\033[41;39mPacking failed. / 打包失败。\033[0m"
		exit
	fi
	echo -e "\n\033[34mRemoving temp directory......\n删除临时目录......\033[0m"
	rm -rf *
	cd ../
	rmdir -v $StDiR/$TmPdIr
	echo -e "\033[1m\033[32m\nPatching completed.\nPlease do not uninstall aapt or zipalign to avoid installation package export failed.\nIf you have update the aapt or zipalign, please run this script again.\n修补完成。\n请不要卸载 aapt 或 zipalign 以免安装包导出失败。\n如果您更新了 aapt 或 zipalign，请再次运行这个脚本。\033[0m"
	exit
else
	#Start here after loading script 脚本加载后从这里开始
	echo -e "\033[1m\033[47;30m\n\nMIT App inventor 2 Patch tool by BUGTeas\nThis script is used to solve the App inventor 2 server cannot export installation package on non-X86_64 Linux system.(because built-in X86_64 programs are used)\nHow it works: replace X86_64 program built into the server with corresponding architecture program installed under the current system\n\nMIT App inventor 2 修补工具 by BUGTeas\n此脚本用于解决 App inventor 2 服务器不能在非 X86_64 的 Linux 系统下导出安装包。（因为使用了内置的 X86_64 程序）\n脚本工作原理：将服务器中内置的 X86_64 程序替换为当前系统下安装的对应架构的程序\n\033[0m"
	$0 chkdir Step1
fi
echo 
