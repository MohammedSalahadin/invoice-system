#Authers
#1. Mohammed Salahadin  Email:Mohammed.salahadinf18@komar.edu.iq
#2. Abdulrahman tawfiq  Email:abdulrahman.tofiqf18@komar.edu.iq
#!/bin/bash

#Defingin colors for using them in the program
Green='\033[1;32m'
Red='\033[1;31m'
Cyan='\033[1;36m'
Yellow='\033[1;33m'
NC='\033[0m' #End of the color
#-e enable interpretation of backslash escapes
echo -e "###################################################################"
echo -e "################# ${Green}   Welcome to invoice app ${NC}  #####################"
echo -e "###################################################################"
echo -e " ${Yellow} To install the software you have to make sure you have internet ${NC} "
echo -e " Connection on your system otherwise it will not be installed \n"
echo -e " Here is the instructions commands Options: "
echo -e " 1 To install invoice system."
echo -e " 2 For Updatig/Modefying the system configuration."
echo -e " 3 To Get reports "
echo -e " 4 To backup your your database"
echo -e " 5 To Restore stored databases"
echo -e " 6 To Run the System"
echo -e " 7 To Remove the system"
echo -e " q To Exit"


#instaling main softwares function
function installSoftware(){
	#update system packages
	echo "$(sudo apt update)"
	#upgrade system packages
	echo "$(sudo apt --assume-yes upgrade)"
	#install apache server
	echo "$(sudo apt-get install apache2)"
	#Restart apache Server
	echo "$(sudo systemctl restart apache2.service)"
	#Install mysql server and give it yes when ever it asks for installing
	echo "$(sudo apt-get --assume-yes install mysql-server)"
	#to  install php8.0
	echo "$(sudo apt --assume-yes install php8.0)"
	#Install php8.0 Required extenstions for runnin the system
	echo "$(sudo apt --assume-yes install php8.0-common)"
	echo "$(sudo apt --assume-yes install php8.0-mysql)"
	echo "$(sudo apt --assume-yes install php8.0-curl)"
	echo "$(sudo apt --assume-yes install php8.0-json)"
	echo "$(sudo apt --assume-yes install php8.0-mbstring)"
	echo "$(sudo apt --assume-yes install php8.0-xml)"
	echo "$(sudo apt --assume-yes install php8.0-zip)"
	echo "$(sudo apt --assume-yes install php8.0-gd)"
	echo "$(sudo apt --assume-yes install php8.0-soap)"
	echo "$(sudo apt --assume-yes install php8.0-tokenizer)"
}

#Configureing softwares function
function softConf(){
	#Configure the system in order to start apache and mysql on reboot
	echo "$(sudo systemctl enable apache2.service)"
	echo "$(sudo systemctl enable mysql.service)"
	#Enable webserver ports
	echo "$(sudo ufw allow 80/tcp)" #Http
	echo "$(sudo ufw allow 443/tcp)" #Https
	echo "$(sudo ufw allow 3306/tcp)" #mysql server
}

#Download system files then extrace and install them into user machine
function dowloadFetch(){
	#Remove the previous invoce files inside html
	echo "$(sudo rm -r /var/www/html/*)"
	#Downloading the system files from the server and fetching them
	#echo "$(sudo wget http://himahotels.com/linux_invoice.zip -O '/tmp/invoice.zip')"
	#Downloading mysql files from the server
	#echo "$(sudo wget http://himahotels.com/invoice_database.sql -O '/tmp/invoice.sql')"
	#extracting the zip file to local server 
	echo "$(sudo chmod 777 /tmp/invoice.sql)"
	echo "$(sudo chmod 777 /tmp/invoice.zip)"
	#Add The default user to the sql file, will call create admin to edit it later
	echo "INSERT INTO invoice_database.users (idusers, username, password, type, phonenumber,email) VALUES ('1', 'admin', 'default', 'admin','0', 'defaultemail');" >> /tmp/invoice.sql
	###################  Setting the database password for root user   ######################
	echo "UPDATE mysql.user SET authentication_string=null WHERE User='root';" >> /tmp/invoice.sql
	echo "flush privileges;" >> /tmp/invoice.sql
	echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';" >> /tmp/invoice.sql
	echo "flush privileges;" >> /tmp/invoice.sql
	##################     End Setting database for root user  ##############################
	echo "$(sudo unzip 'files.zip' -d '/var/www/html')"
	#execute the database to the database server
	echo  "$(sudo mysql -u root -proot  < database.sql)"
	###########    Setting the permistion of the php files to be full control by root and only executable by other users and groups
	echo "$(sudo chomd 711 /var/www/html)"
}

function createAdmin(){
	echo -e "###############    Create/Update new admin login account   ##################\n"
	echo -e "Please insert your information to create username for the first use  \n"
	echo -e "Admin User Name:"
	read user
	echo -e "Admin Password:"
	read password
	echo -e "Admin Phone Number:"
	read phone
	echo -e "Admin Email Address:"
	read email
	#Write the user inputs combined with sql code that contains the admin info and store the file in /tmp/createadmin.sql
	#The Original database should include a default record that contains the default information, by using below sql coommand
	#we will be able to update the information for that record.
	echo "UPDATE  invoice_database.users set username='$user',password='$password',type='admin',phonenumber='$phone',email='$email' WHERE (idusers = '1'); "  > /tmp/createadmin.sql
	#Execute the sql that has the admin login information to mysql server
	echo -e "$(sudo mysql -u root -proot -h 127.0.0.1 < /tmp/createadmin.sql)"
	#Remove the created file for security reasons
	echo -e "$(sudo rm /tmp/createadmin.sql)"
	echo -e "${Green}Admin Have been updated successfully! ${NC}"
}

function run(){
	var="$(hostname)"
	echo "$(firefox http://"$var")"
}


#For installing Invoice software
function installall(){
	###  Installing required software and configure it for running the system
	installSoftware
	#software configuration
	softConf
	### For Downloading and fetching the system
	dowloadFetch	#Create the first admin account
	createAdmin
	#running the system
	run
}

function configuration(){
	echo "Welcome to configure your invoice system"
	echo "########################################"
	echo "1 To update you localhost Domain name"
	echo "2 To insert new Employee Account"
	echo "3 To Update Current admin account"
	read input2
	if [[ $input2 == 1 ]];then
		localhost_change
	elif [[ $input2 == 2 ]];then
		addEmployee
	elif [[ $input2 == 3 ]];then
		createAdmin
	else
		echo -e "${Red} You have chosen a wrong option!${NC} Please try again!"
		configuration
	fi

}

function localhost_change(){
	echo -e "#################  Change the site domain name    ##################"
	echo -e "Please Enter the new domain name:"
	read admin
	#give premision to modefy host and hostname files
        echo "$(sudo chmod 777 /etc/hostname)"
	echo "$(sudo chmod 777 /etc/host)"
        #change the localhost 127.0.0.1 to the admin name
        echo "$(sudo echo "$admin" > /etc/hostname)"
	echo "$(sudo echo "127.0.0.1 $admin" > /etc/host)"
	echo "$(sudo hostname "$admin")"
	echo "$(sudo service apache2 restart)"
echo -e "${Cyan}Your domain name is now:${NC} ${Yellow} http://$admin ${NC}"
}

function addEmployee(){
	echo "User Name:"
	read userName
	echo "Password:"
	read password
	echo "Phone Number:"
	read phone
	echo "Email:"
	read email
	
	#Create an sql file of contains 
	#we will be able to update the information for that record.
	echo "INSERT INTO invoice_database.users (username, password, type, phonenumber, email) VALUES ('$userName', '$password', 'user', '$phone', '$email');" > /tmp/adduser.sql
	#Execute the sql that has the admin login information to mysql server
	echo -e "$(sudo mysql -u root -proot < /tmp/adduser.sql)"
	#Remove the created file for security reasons
	echo -e "$(sudo rm /tmp/adduser.sql)"
	echo "${Green}User $userName Have been added to the system ${NC}"
	#Create New linux user using this username and password
	echo "$(sudo useradd -m $userName)"
	echo "$(sudo echo "$userName:$password" | sudo chpasswd)"
	#Adding the user which have been created to the mail gorup
	echo "$(sudo usermod -aG mail $userName)"
	echo -e "User ${Cyan} $userName ${NC} Have been added to the mail group"

}
function daily_report(){
	#this command will execut the command
	# should specify the user name and password for login to the database by using -u for the username and -p for the password
	#-h is used to connect to the host that is running the database
	#-D to select the database that we are going to work with
	# -e The most  importatn paramater that sends the query to the database to execute it.
	echo "######### Getting daily report ##########"
	echo "$(mysql -u root -proot -h 127.0.0.1 -D invoice_database -e 'SELECT * FROM invoice_database.sell_report;SELECT * FROM invoice_database.sell_report_invoices;SELECT * FROM invoice_database.total_invoices_price_for_today;' -t)"
}

#This function will be responsible for getting a custorm report about what 
#have been sold and the quantity 
function custom_report(){
	echo "#########  Getting report using custom date  #####"
	echo "Please Input the date in the Following format dd/mm/yy"
	echo "Please input from date:"
	read dateFrom
	echo "Please input to date:"
	read dateTo
	##echo $dateFrom
	if [[ "$dateFrom"  != "" && "$dateTo" != "" ]];then
		#
		echo "$(sudo  mysql -u root -proot -h 127.0.0.1 -D invoice_database -e 'call invoice_database.TOTAL_INVOICES_PRICES_FOR_SPECIFIC_DATE("'$dateFrom'", "'$dateTo'");')"
	else
		echo -e "${Red}You havn't enter the dates, Please Try again ${NC}"
		custom_report
	fi
}

#this function is responsible for calling the report functions
function reports(){
	echo "Please Choose the type of report you want to get"
	echo -e "1  Daily Report\n 2  Custom Date Report"
	read report
	if [[ $report == 1 ]];then
		daily_report
	elif [[ $report == 2 ]];then
		custom_report
	else
		echo -e "${Red}Wrong input, Please select from the options below ${NC}"
		reports
	fi
}
#This function is responsible for backing up the database
function backup(){
	echo "#############     Backup  Your database   #######"
	currentdate=$(date '+%Y-%m-%d %H:%M:%S')
	echo "$(mysqldump -u root -proot invoice_database > ~/Desktop/invoice_"$currentdate".sql)"
	echo -e "${Cyan}Backing up your database is done and it is stored on your desktop ${NC}"

}
#This function is responsible for restoring the database
function restore(){
	echo "############     Restoring your database    #######"
	echo "Please Input one of the backups to restore"
	echo "$(cd ~/Desktop;ls *.sql)"
	read restorefile
	#if [[ restorefile != "" ]];then
	echo "$(mysql -u root -proot invoice_database < ~/Desktop/"$restorefile")"
	echo -e "${Green} File have been restored successfully ${NC}"

}

function removeSystem(){
	echo "$(mysql -u root -proot -h 127.0.0.1 -D invoice_database -e 'drop database invoice_database;')"
	echo "$(sudo rm -r /var/www/html ; sudo mkdir /var/www/html)"
	echo "${Green} System have been removed ${NC}"
}

read input
if [[ $input == '1' ]]; then
	#in order to store the errors of this function
	var=($(sudo ls /var/www/html))

        numFiles="${#var[@]}"
        if [[ $numFiles != 20 ]]
        then 
                installall
        else
                echo -e "${Red}System is already installed${NC}"
        fi


elif [[ $input == '2' ]];then
	var=($(sudo ls /var/www/html))
        numFiles="${#var[@]}"
        if [[ $numFiles == 20 ]]
        then 
                configuration
        else
                echo -e "${Red}Please install the system first!${NC}"
        fi
elif [[ $input == '3' ]];then
	var=($(sudo ls /var/www/html))
        numFiles="${#var[@]}"
        if [[ $numFiles == 20 ]]
        then 
                reports
        else
                echo -e "${Red}Please install the system first!${NC}"
        fi

elif [[ $input == '4' ]];then
	var=($(sudo ls /var/www/html))
        numFiles="${#var[@]}"
        if [[ $numFiles == 20 ]]
        then 
                backup
        else
                echo -e "${Red}Please install the system first!${NC}"
        fi

elif [[ $input == '5' ]];then
	var=($(sudo ls /var/www/html))
        numFiles="${#var[@]}"
        if [[ $numFiles == 20 ]]
        then 
                restore
        else
                echo -e "${Red}Please install the system first!${NC}"
        fi

elif [[ $input == '6' ]];then
	var=($(sudo ls /var/www/html))
        numFiles="${#var[@]}"
        if [[ $numFiles == 20 ]]
        then 
                run
        else
                echo -e "${Red}Please install the system first!${NC}"
        fi
elif [[ $input == '7' ]];then
	var=($(sudo ls /var/www/html))
        numFiles="${#var[@]}"
        if [[ $numFiles == 20 ]]
        then 
                removeSystem
        else
                echo -e "${Red} The system is already uninstalled! ${NC}"
        fi
elif [[ $input == 'q' || $input == 'Q' ]];then
	echo -e "${yellow}----------  GOOD BYE  --------------- ${NC}"

else
	echo -e "You have enterd a wrong option. Please Try Again!"

fi
