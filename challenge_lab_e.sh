#!/bin/bash

# DVA233 - Linux
# Erik Kamph
# Challenge Lab E

#Store menu options selected by the user
RESULT=/tmp/menu.sh.$$
#Store input made from the user
INPUT=/tmp/input.sh.$$
#Store output generated somewhere
OUTPUT=/tmp/output.sh.$$
#Temporary store fields used for listing of group or user
FIELDS=/tmp/fields.sh.$$

CHOICE="none"

function add_group() {
	dialog --title "group:add" --inputbox "What is the name of the group you want to add?" 8 60 2> $INPUT
	GROUPNAME=$(<"${INPUT}")
	EXISTS=`grep ${GROUPNAME} /etc/group | head -n1 | cut -d: -f1`

	while [ "${GROUPNAME}" == "${EXISTS}" ]
	do
		dialog --title "group:add" --inputbox "The group already exists!\nWhat is the name of the group you want to add?" 9 60 2> $INPUT
        	GROUPNAME=$(<"${INPUT}")
		EXISTS=`grep ${GROUPNAME} /etc/group | head -n1 | cut -d: -f1`
	done

	groupadd ${GROUPNAME}
}

function show_groups() {
	#dialog --title "group:list" --msgbox "$(for group in `compgen -g`; do echo $group; done)" 23 60 --scrollbar
	dialog --title "group:list" --textbox /etc/group 23 60
}

function show_association() {
	dialog --inputbox "Which group do you want information of?" 8 60 2> $INPUT
	grp=$(<"${INPUT}")
        fields='GROUP:PASS_HOLDER:ID::USERS'
	echo $fields > $FIELDS
	dialog --title "group:view" --msgbox "$(for i in 1 2 3 5; do echo `cut -d: -f$i $FIELDS`'|'`grep ${grp} /etc/passwd | head -n1 | cut -d: -f$i`; done)" 20 30
}

function add_user() {
	dialog --inputbox "What is the name of the user you want to add?" 8 60 2> $INPUT
	USERNAME=$(<"${INPUT}")
	EXISTS=`grep ${USERNAME} /etc/passwd | head -n1 | cut -d: -f1`

	while [ "${USERNAME}" == "${EXISTS}" ]
	do
		dialog --inputbox "The user already exists!\nWhat is the name of the user you want to add?" 8 60 2> $INPUT
        	USERNAME=$(<"${INPUT}")
		EXISTS=`grep ${USERNAME} /etc/passwd | head -n1 | cut -d: -f1`
	done

	adduser $USERNAME
}

function list_users() {
	#dialog --title "user:list" --msgbox "$(for user in `compgen -u`; do echo $user; done)" 23 60
	dialog --title "user:list" --textbox /etc/passwd 23 60
}

function view_properties() {
	dialog --inputbox "What user do you want to view information about?" 8 60 2> $INPUT
	usr=$(<"${INPUT}")
	fields='Username::User_ID:Group_ID:Comments:Home_dir:Shell'
	echo $fields > $FIELDS
	dialog --title "user:view" --msgbox "------------------------\n$(for i in 1 3 4 5 6 7; do printf '%-10s|%-12s' `cut -d: -f$i $FIELDS` `grep $usr /etc/passwd | cut -d: -f$i`; done)\n------------------------" 12 28
}

function modify_user() {
	dialog --title "user:modify" --inputbox "Which user do you want to modify?" 8 60 2> $INPUT

	USER=$(<"${INPUT}")
	USRMOD="none"

	while [ "$USRMOD" != "" ];
	do
		dialog --title "user:modify" --menu "What do you want to modify? Pressing '<Cancel>' will exit this menu" 23 60 23 "comment" "Changes the comment section on the user" \
											"home_dir" "Changes the home directory on the user" \
											"change_name" "Changes the login name on the user" \
											"password" "Changes the password on this user" \
											"del_user" "Deletes this user" 2> $INPUT
		USRMOD=$(<"${INPUT}")
		case $USRMOD in
			comment) change_comment $USER;;
			home_dir) change_home $USER;;
			change_name) change_name $USER;;
			password) change_pass $USER;;
			del_user) delete_user $USER;;
		esac
	done
}

function change_comment() {
	dialog --title "change_comment" --inputbox "What is the new comment?" 8 60 2> $INPUT
	COMMENT=$(<"${INPUT}")
	usermod -c $COMMENT $1
}

function change_home() {
	dialog --title "change home" --inputbox "Where do you want to place the new home? (Include full path ex. /home/newDir):" 9 60 2> $INPUT
	HOME=$(<"${INPUT}")
	PREV_HOME=`grep $1 /etc/passwd | cut -d: -f6`
	if [ -d $PREV_HOME ];
	then
		mv $PREV_HOME $HOME
		usermod -d $HOME $1
	else
		mkdir $HOME
		usermod -d $HOME $1
	fi
}

function change_name() {
	dialog --title "change name" --inputbox "What is the new loginname of the user?" 8 60 2> $INPUT
	NEW_NAME=$(<"${INPUT}")
	usermod --login $NEW_NAME $1
	USER=$NEW_NAME
}

function change_pass() {
	dialog --title "change password" --msgbox "Changing password for $1" 8 60 --no-cancel
	passwd $1
}

function delete_user() {
	dialog --title "delete user" --yesno "Are you sure you want to delete ths user named $1?" 8 60 2>$?

	ANSWER=$?

	if [ $ANSWER -eq 0 ];
	then
		dialog --title "delete user" --msgbox "Deleting user with name: $1" 7 60
		deluser $1
	else
		dialog --title "delete user" --msgbox "Not deleting user with name: $1" 7 60
	fi
}

function view_contents() {
	dialog --title "CONTENTS OF FOLDER" --fselect / 23 60
}

function add_folder() {
	dialog --title "Add a folder to the system" --dselect / 23 60 2> $INPUT
	LOCATION=$(<"${INPUT}")

	while `test -d ${LOCATION}`;
	do
		dialog --title "Add a folder to the system" --dselect $LOCATION 23 60 2> $INPUT
		LOCATION=$(<"${INPUT}")
	done

	dialog --title "Adding folder" --msgbox "Adding folder at location $LOCATION" 8 60 2>$INPUT

	mkdir $LOCATION
}

function modify_group() {
	dialog --title "group:modify" --inputbox "Type the name of the group to modify" 8 60 2> $INPUT
	GROUP=$(<"${INPUT}")
	GRP_CHOICE="none"

	while [ "$GRP_CHOICE" != "" ];
	do
		dialog --title "group:modify" --menu "Select something to do with the group $GROUP" 23 60 23 "name" "Change group name" \
												"add_user" "Add a user to the group" \
												"remove_user" "Remove a user from the group" \
												"group_id" "Change group ID" \
												"remove_group" "Delete the group from the system" 2> $INPUT
		GRP_CHOICE=$(<"${INPUT}")

		case $GRP_CHOICE in
			name) group_name $GROUP;;
			add_user) group_user_add $GROUP;;
			remove_user) group_user_remove $GROUP;;
			group_id) group_id $GROUP;;
			remove_group) rm_group $GROUP;;
		esac
	done
}

function group_name() {
	dialog --title "Change the group name" --inputbox "Type the new name of the group $1" 8 60 2>$INPUT
	NEW_NAME=$(<"${INPUT}")
	groupmod -n $NEW_NAME $1
	GROUP=$NEW_NAME
}

function group_user_add() {
	dialog --title "Add users to $1" --inputbox "Type the name or names(separated with space)" 8 60 2>$INPUT
	USERS=$(<"${INPUT}")
	for user in $USERS
	do
		usermod -G $1 $user
	done
}

function group_user_remove() {
	dialog --title "Remove users from $1" --inputbox "Type the name or names(separated with space)" 8 60 2>$INPUT
	USERS=$(<"${INPUT}")
	for user in $USERS
	do
		gpasswd -d $user $1
	done
}

function group_id() {
	dialog --title "Changes the group ID" --inputbox "Type a new group ID(4 digits)" 8 60 2> $INPUT
	GID=$(<"${INPUT}")
	groupmod -g $GID $1
}

function rm_group() {
	dialog --title "Removing group" --yesno "You are about to remove the group $1\nfrom the system. Are you sure?" 10 60 2>$?
	ANSWER=$?
	if [ $ANSWER -eq 0 ];
	then
		dialog --title "Removing group" --msgbox "Now removing group with name $1" 8 60 2>$?
		groupdel $1
		GROUP=""
		GRP_CHOICE=""
	else
		dialog --title "Removing group" --msgbox "Not removing group with name $1" 8 60 2>$?
	fi
}

function view_folder_properties() {
	dialog --title "Choose a folder to view properties from" --dselect / 23 60 2> $INPUT
	location=$(<"${INPUT}")

	stat $location > $FIELDS
	dialog --title "Viewing permissions" --textbox $FIELDS 13 80
}

function modify_folder() {
	dialog --title "folder:modify" --dselect / 23 60 2>$INPUT
	location=$(<"${INPUT}")
	CMENU="none"

	while [ "$CMENU" != "" ];
	do
		dialog --title "folder:modify" --menu "Select something from the menu to change" 23 60 23 "permissions" "Change permissions on the folder" \
													"owner" "Change the owner of the folder" \
													"group" "Change the group of the folder" \
													"name" "Change the name on the folder" 2> $INPUT
		CMENU=$(<"${INPUT}")

		case $CMENU in
			permissions) change_perm $location;;
			owner) change_owner $location;;
			group) change_group $location;;
			name) change_folder_name $location;;
		esac
	done
}

function change_folder_name() {
	dialog --ok-label "Byt namn" --title "Changing name on folder" --dselect $1 23 60 2> $INPUT
	NEW_PATH=$(<"${INPUT}")
	mv $1 $NEW_PATH
}

function change_group() {
	dialog --title "Changing group owner on folder" --inputbox "Changing group on $1\nNot like changing user, this time only type the group name!" 10 60 2>$INPUT
	GROUP=$(<"${INPUT}")
	chgrp $GROUP $1
}

function change_owner() {
	dialog --title "Changing owner on folder" --inputbox "Changing owner on $1\nType the name of the new owner\nIf you want you can change group to just add colon infront like :error" 12 60 2>$INPUT
	OWNER=$(<"${INPUT}")
	chown $OWNER $1
}

function change_perm() {
	dialog --title "Changing permissions" --inputbox "Changing permissions on $1\nFormat input like: xxxx or xxx with digits 1-7\n1=x 2=w 4=r" 12 60 2>$INPUT
	PERMISSIONS=$(<"${INPUT}")

	chmod $PERMISSIONS $1
}

while [ "$CHOICE" != "" ];
do
	dialog --cancel-label "Exit" --title "User and Group Manager" --menu "Select a user management action from the menu below:" 23 60 23 "group:add" "Create a new group" \
								"group:list" "List system groups" \
								"group:view" "List user associations for group" \
								"group:modify" "Modify user associations for group" \
								"user:add" "Create a new user" \
								"user:list" "List system users" \
								"user:view" "View user properties" \
								"user:modify" "Modify user properties" \
								"folder:add" "Create a new folder" \
								"folder:list" "List folder contents" \
								"folder:view" "View folder properties" \
								"folder:modify" "Modify folder properies" 2>"${RESULT}"
	CHOICE=$(<"${RESULT}")

	case $CHOICE in
		group:add) add_group;;
		group:list) show_groups;;
		group:view) show_association;;
		group:modify) modify_group;;
		user:add) add_user;;
		user:list) list_users;;
		user:view) view_properties;;
		user:modify) modify_user;;
		folder:add) add_folder;;
		folder:list) view_contents;;
		folder:view) view_folder_properties;;
		folder:modify) modify_folder;;
	esac
done

#Delete the temporary files made by the application
[ -f $RESULT ] && rm $RESULT
[ -f $INPUT ] && rm $INPUT
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $FIELDS ] && rm $FIELDS
