#!/bin/bash

#para la creacion de usuarios es necesario ser root, con esto lo controlamos.
if [ $(whoami) != "root" ]; then
    echo -e "\e[31mTienes que ser root para ejecutar este script\e[0m"
    echo -e "\e[31mEjecuta "sudo su" para ser root\e[0m"
    exit 1
fi
echo -e "\n"
echo "GESTION DE USUARIOS"
echo ""
echo "1) Crear Usuario"
echo "2) Eliminar Usuario"
echo "3) Crear Grupo"
echo "4) Cambiar Contraseña a Usuario"
echo "5) Cambiar nombre de usuario"
echo "6) Ver Datos de un Usuario "
echo "7) Ver usuario logueado en este momento y usuarios del sistema"
echo "8) Mover usuario a grupo"
echo "9) Salir"
echo -e "\n"
echo "Opcion: " 
read op

#Al elegir la opcion pasa a casa caso
case $op in

#Se calcula el numero de usuario para poder sumarle uno cada vez que se inserte uno nuevo

1) num=0
for i in $(cut -d: -f3 /etc/passwd)
do
if [ $i -gt $num -a $i -lt 5000 ]
then num=$i
fi
done
num=$(($num+1))
numUsu=$num

echo -e "\e[96mIngrese el nombre del usuario\e[0m"
read nombre

echo -e "\e[96mIngrese apellidos\e[0m"
read apellidos

#Se declara el home por defecto

personal="/home/$nombre"
echo -e "\e[96mSu home por defecto sera $personal\e[0m"
echo "-----------------------------------"


#Informamos del numero de usuario

echo -e "\e[96mSu numero de usuario es $numUsu\e[0m"
echo "-----------------------------------"
#se asigna el grupo 1000 por defecto

grupo=1000
echo -e "\e[96mSu grupo por defecto sera $grupo\e[0m"
echo "-----------------------------------"

#se declara la sintaxsis para el archivo passwd

cad="$nombre::$numUsu:$grupo:$nombre $apellidos:$personal:/bin/bash"

#introducimos esa cadena al fichero

echo $cad >> /etc/passwd

#cambiamos contraseña del usuario 

passwd $nombre

#sacamos la linea de la contraseña del fichero passwd y lo guardamos en un fichero aparte

cif=`sed -n "$"p /etc/passwd`
echo $cif > contr

#para poder cifrar la contraseña y añadirla al fichero shadow
#obtenemos la clave del fichero creado

pass=`cut -d: -f2 contr` 
#borramos el fichero
rm -f contr

#eliminamos la ultima linea del fichero ya que vamos a añadir otra con la pass cifrada
sed -i "$"d /etc/passwd

cad2="$nombre:x:$numUsu:$grupo:$nombre $apellidos:$personal:/bin/bash"

#añadimos al fichero passwd 

echo $cad2 >> /etc/passwd

#añadimos la pass al fichero shadow

cad3="$nombre:$pass:17001:0:99999:7:::"
echo $cad3 >> /etc/shadow


#hacemos copia de skel para crear el directorio de forma correcta.

echo -e "\e[96mSe copian los archivos y ficheros necesarios de skel\e[0m"
cp -R /etc/skel /home
mv /home/skel /home/$nombre
chown -R $nombre /home/$nombre
chgrp $grupo /home/$nombre

# Resumen de los datos introducidos

echo -e "\e[96m Los datos ingresados son los siguientes:\e[0m"
echo "****************************************"
echo -e "\n"
echo -e "\e[94mNombre del usuario: $nombre"
echo -e "\e[94mApellidos del usuario : $apellidos"
echo -e "\e[94mNumero de usuario: $numUsu"
echo -e "\e[94mGrupo del usuario: $grupo"
echo -e "\e[94mCarpeta personal del usuario: $personal"
echo -e "\n"
echo "-------------------------------------------"
echo -e "\e[92mUsuario creado correctamente"

sleep 2
clear
./UsuariosAna.sh

;;

#Borrar usuarios

2) echo -e "\e[96mEstos son los usuarios que estan creados en el sistema\e[0m"
ls -l /home/
echo ""
echo -e "\e[96mIndique el nombre del usuario a borrar\e[0m"
read user2
userdel -f -r $user2
echo -e "\e[92mse borro el usuario $user2\e[0m"
sleep 2
./UsuariosAna.sh
;;

#Crear grupo
3) 
echo -e "\e[96mInserte el nombre del grupo que desea crear\e[0m"
read grup
groupadd $grup
echo -e "\e[92mse inserto correctamente el grupo $grup\e[0m"
sleep 2

./UsuariosAna.sh
;;

# Cambiar contraseña usuario
4) 
echo -e "\e[96mIngrese Nombre de Usuario:\e[0m"
read us
passwd $us
echo -e "\e[96mse cambio la contraseña al usuario $us con exito\e[0m"
sleep 2
clear
./UsuariosAna.sh
;;

# Cambiar nombre usuario
5)echo -e "\e[96mSe va a cambiar el nombre de usuario, inserte el usuario a modificar\e[0m"
read nombre
echo -e "\e[96mIndique el nuevo nombre de usuario\e[0m"
read usu
usermod -d  $usu $nombre
usermod -l $usu $nombre
echo -e "\e[92mEl nuevo nombre de usuario es $usu\e[0m"
sleep 2
echo "\e[92mnombre de usuario cambiado correctamente\e[0m"
./UsuariosAna.sh
;;

#Consultar informacion usuario
6) echo -e "\e[96mIngrese Nombre de Usuario a Consultar\e[0m"
read user
id $user
sleep 2
./UsuariosAna.sh

;;
#Consultar usuarios logueados y usuarios dados de alta en el sistema
7) echo -e "\e[96mConsultar usuarios logueados actualmente\e[0m"
who
sleep 2
echo -e "\e[96mAcontinuacion se muestran los usuarios que pertenecen al sistema\e[0m"

ls /home/
sleep 2

./UsuariosAna.sh

;;


8)
#Añadir usuario a grupo
echo -e "\e[96mInserte el nombre del usuario que quiere añadir a un grupo\e[0m"
read nomb
echo -e "\e[96mInserte el nombre del grupo a añadir\e[0m"
read gr
adduser $nomb $gr
echo ""
echo  -e "\e[92mSe añadio $nomb a $gr\e[0m"
sleep 2

./UsuariosAna.sh

;;

9)
echo -e "\e[33mUsted ha deseado salir\e[0m"
sleep 2
clear
exit

;;

*) echo -e "\e[91mPor Favor, escoja una opción válida\e[0m"

sleep 2
clear
./UsuariosAna.sh

;;

esac


