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
		$0 $2 $3 $4
	elif [ "$num" = "Y" ];then
		echo 
		$0 $2 $3 $4
	else
		echo -e "\nOperation cancelled by User.\n操作被用户取消。"
	fi
	exit
elif [ "$1" = "chkdir" ];then
	echo -e "\033[34m\nSearching for target patch file \"BuildServer.jar\" ......\n正在寻找目标修补文件“BuildServer.jar”......\033[0m"
	for setpath in "./BuildServer/BuildServer.jar" "./buildserver/buildserver.jar" "./BuildServer/buildserver.jar" "./buildserver/BuildServer.jar" "./buildserver.jar" "./BuildServer.jar" none
	do
		if [ $setpath = "none" ];then
			echo -e "Cannot find \"BuildServer.jar\",please input the full path. (support ./ & ../)\n无法找到“BuildServer.jar”文件，请手动输入完整路径。（支持 ./ 和 ../）"
			$0 chkdir2 $2
		elif [ ! "$($0 chkdir1 $setpath $2 back)" = "none" ];then
			$0 chkdir1 $setpath $2
			break
		fi
	done
	exit
elif [ "$1" = "chkdir1" ];then
	if [ "$4" = "back" ];then
		if [ ! -e "$2" ];then
			echo "none"
		fi
	else
		if [ -d "$2" ];then
			echo "This is a directory. / 这是一个文件夹。"
			$0 chkdir2 $2
		elif [ -e "$2" ];then
		filepath=$(realpath $2)
			echo -e "\033[32mFile has been found / 文件已找到\n$filepath\033[0m"
			$0 $3 $filepath
			exit
		else
			echo "Cannot find this file. / 找不到文件。"
			$0 chkdir2 $2
		fi
	fi
	exit
elif [ "$1" = "chkdir2" ];then
	read -p "Path / 路径 :" setpath
	if [ $setpath ];then
		$0 chkdir1 $setpath $2
	else
		$0 $1 $2
	fi
	exit
elif [ "$1" = "Step1" ];then
	echo -e "\033[34m\nChecking required program / 检查所需的程序......\033[0m"
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
		$0 Step2 $2
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
	$0 choice RepackStart $2
	exit
elif [ "$1" = "RepackStart" ];then
	TmPdIr=$(pwd)/TempOfBugteas
	BuD=BuildServer
	echo -e "\033[34mCreate temp directory / 创建临时目录 ......\033[0m"
	mkdir -v $TmPdIr
	cd $TmPdIr
	echo -e "\033[34m\nUnpacking file / 正在解包文件 ......\033[0m"
	UnP="jar -xvf $2"
	echo "$UnP"
	UnPsT=$($UnP)
	if [ -d "$TmPdIr/tools/" ];then
		echo -e "\033[32mUnpacking successful. / 解包成功。\033[0m"
	else
		echo -e "$UnPsT\n\n\033[41;39mUnpacking failed. / 解包失败。\033[0m"
		cd ../
		rm -rf $TmPdIr
		exit
	fi
	echo 
	if [ -e "$2.bak" ];then
		echo -e "\033[34mRemove older file / 正在删除旧的文件 ......\033[0m"
		rm -v $2
	else
		echo -e "\033[34mBackup original file / 正在备份原有文件 ......\033[0m"
		mv -v $2 $2.bak
	fi
	echo -e "\033[34m\nReplacing files / 正在替换文件 ......\033[0m"
	if [ -e "$TmPdIr/tools/linux/aapt" ];then
		rm -v $TmPdIr/tools/linux/aapt
		cp -v $(../$0 search aapt) $TmPdIr/tools/linux/
	fi
	if [ -e "$TmPdIr/tools/linux/aapt2" ];then

		if [ ! "$(../$0 search aapt2)" = "none" ] ;then
			rm -v $TmPdIr/tools/linux/aapt2
			cp -v $(../$0 search aapt2) $TmPdIr/tools/linux/
		fi
	fi
	if [ -e "$StDiR/$TmPdIr/tools/linux/zipalign" ];then
		rm -v $TmPdIr/tools/linux/zipalign
		cp -v $(../$0 search zipalign) $TmPdIr/tools/linux/
	fi
	echo -e "\033[34m\nRepacking file / 正在重新打包文件 ......\033[0m"
	RpK="jar -cvf $2 *"
	echo "$RpK"
	RpKsT=$($RpK)
	if [ -e "$2" ];then
		echo -e "\033[32mPacking successful. / 打包成功。\033[0m"
	else
		echo -e "$RpKsT\n\n\033[41;39mPacking failed. / 打包失败。\033[0m"
		cd ../
		rm -rf $TmPdIr
		exit
	fi
	echo -e "\n\033[34mRemoving temp directory / 删除临时目录 ......\033[0m"
	rm -rf *
	cd ../
	rmdir -v $TmPdIr
	echo -e "\033[1m\033[32m\nPatching completed.\nPlease do not uninstall aapt or zipalign to avoid installation package export failed.\nIf you have update the aapt or zipalign, please run this script again.\n修补完成。\n请不要卸载 aapt 或 zipalign 以免安装包导出失败。\n如果您更新了 aapt 或 zipalign，请再次运行这个脚本。\033[0m"
	exit
else
	#Start here after loading script 脚本加载后从这里开始
	echo -e "\033[1m\033[47;30m\n\nMIT App inventor 2 Patch tool by BUGTeas\nThis script is used to solve the App inventor 2 server cannot export installation package on non-X86_64 Linux system.(because built-in X86_64 programs are used)\nHow it works: replace X86_64 program built into the server with corresponding architecture program installed under the current system\n\nMIT App inventor 2 修补工具 by BUGTeas\n此脚本用于解决 App inventor 2 服务器不能在非 X86_64 的 Linux 系统下导出安装包。（因为使用了内置的 X86_64 程序）\n脚本工作原理：将服务器中内置的 X86_64 程序替换为当前系统下安装的对应架构的程序\n\033[0m"
	$0 chkdir Step1
fi
echo 
