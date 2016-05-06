#!/bin/bash
mysql_user="root"
mysql_passwd="admin0"


#当天备份日期
now=`date +%Y%m%d`

#备份的主要目录
backupDir="/data/backup/"

#完整备份目录名
completeDir=$backupDir"full_all"

#增量备份主目录
incMainDir=$backupDir"inc"

#要备份的数据库名字，多个以空格隔开
databases="hades"

#每天增量备份时的目录名
incNowDir=$incMainDir"/$now"

mkdir -p $incMainDir

backup(){
    if [[ -d $completeDir ]];then
        echo "The database has all backuped ago, now excute increment backup!"
        echo "*****************  Now excute First inc backup   **********************************"
        if [ "`ls -A $incMainDir`" = "" ];then
            innobackupex --defaults-file=/etc/mysql/my.cnf --incremental $incNowDir --no-timestamp --incremental-basedir=$completeDir --user=$mysql_user --password=$mysql_passwd
        else
            echo "+++++++++++++++++  Now excute last inc backup follow the lastest day inc backup  +++++++++++++++++"
            incBefDirsuf=`ls -t $incMainDir | head -1`
            echo $incBefDirsuf
            incBefDir=$incMainDir"/"$incBefDirsuf
            echo $incBefDir
            innobackupex --defaults-file=/etc/mysql/my.cnf --incremental $incNowDir --no-timestamp --incremental-basedir=$incBefDir --user=$mysql_user --password=$mysql_passwd
        fi
    else
        echo "The database has never backup ago, now create the backup dir to all backup!"
        echo "===============   Now excute the fullall backup  =========================="

    	innobackupex --defaults-file=/etc/mysql/my.cnf --no-timestamp --user=$mysql_user --password=$mysql_passwd --databases=$databases $completeDir
    fi

}

main(){
    backup
}

main
