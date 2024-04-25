#!/bin/bash


#Colours
endColour="\033[0m\e[0m"
green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${yellow}[+]${endColour}${gray} El dinero que tienes actualmente es: ${endColour}${yellow}$initialMoney$ ${endColour}"
  echo -e "${yellow}[+]${endColour}${gray} Se han hecho hasta ahora${endColour}${yellow} $play_counter${endColour}${gray} jugadas${endColour}"
  echo -e "\n${red}[!] Saliendo...${endColour}\n"
  tput cnorm; exit 1
}

# Ctrl+C 
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellow}[+]${endColour}${gray} Uso${endColour}${red}:${endColour}${purple} $0${endColour}\n"
  echo -e "\t${blue}.-)${endColour}${gray} Indicar tanto la tecnica como el dinero inicial${endColour}"
  echo -e "\t${blue}-h)${endColour}${gray} Mostrar el Panel de ayuda${endColour}"
  echo -e "\t${blue}-m)${endColour}${gray} Indicar cual es el monto inicial${endColour}"
  echo -e "\t${blue}-t)${endColour}${gray} Indicar la tecnica que utilizara${endColour}${purple} {${endColour}${yellow}martingala${endColour}${blue}/${endColour}${yellow}inverseLabrouchere${endColour}${blue}/${endColour}${yellow}fibonacci${endColour}${purple}}${endColour}\n"
  exit 1
}

#Aqui se pide una serie de parametros para empezar apostar
function martingala(){
  echo -e "\n${yellow}[+]${endColour}${gray} Su dinero actual es ${red}: ${endColour}${yellow}$initialMoney$ ${endColour}"
  
  echo -ne "${yellow}[+]${endColour}${gray} Con cuanto dinero quieres empezar apostar${endColour}${blue}?${endColour} ${red}->${endColour} " && read initial_bet
    
  if [[ ! $initial_bet =~ ^[0-9]+$ ]]; then
    echo -e "\n${red}[!] El valor ingresado debe ser un numero${endColour}\n"
    exit 1
  fi

  if [ "$initial_bet" -gt "$initialMoney" ]; then
    echo -e "\n${red}[!] No puedo apostar mas de lo que tiene, su dinero total es: ${endColour}${yellow}$initialMoney$ ${endColour}\n"
    exit 1
  fi
 
  echo -ne "${yellow}[+]${endColour}${gray} A que quieres apostar continuamente${endColour}${blue}?${endColour} ${blue}(${yellow}par${endColour}${blue}/${endColour}${yellow}impar${endColour}${blue})${endColour} ${red}->${endColour} " && read par_impar 
  
  if [[ ! $par_impar =~ ^(par|impar)$ ]]; then
    echo -e "\n${yellow}[+]${endColour}${red}Seleccione una opcion valida${endColour} ${blue}(${endColour}${yellow}par${endColour}${blue}/${endColour}${yellow}impar${endColour}${blue})${endColour}\n" 
    exit 1
  fi

  echo -e "\n${yellow}[+]${endColour}${gray} Su apuesta inicial es de ${endColour}${yellow}$initial_bet$ ${endColour}a ${yellow}$par_impar${endColour}"
 
  backup_bet=${initial_bet}
  bad_plays="[ "
  declare -i play_counter=1
  declare -i top_money=$initialMoney
  
  tput civis
  while true; do
    initialMoney=$(($initialMoney-$initial_bet))
   
    if [ "$initialMoney" -lt 0 ]; then
      echo -e "\n${red}[!] Te has quedado sin dinero, no puedes seguir apostando${endColour} ${turquoise}:(${endColour}\n"
      echo -e "${yellow}[+]${endColour}${gray} Han habido un total de ${endColour}${yellow}$play_counter${endColour}${gray} jugadas${endColour}"
      echo -e "${yellow}[+]${endColour}${gray} Se representa en un Array todas las malas jugadas que han salido para perder${endColour}"
      bad_plays_reformed=$(echo $bad_plays | sed "s/,$/ /")
      echo -e "${yellow} ->${endColour}${red} $bad_plays_reformed]${endColour}"
      echo -e "\n${yellow}[+]${endColour}${gray} El maximo ganado antes de perderlo todo es: ${endColour}${yellow}$top_money$ ${endColour}\n"
      tput cnorm; exit 0
    fi

    random_number=$(($RANDOM % 37))
    
    echo -e "\n${yellow}[+]${endColour}${gray} Has apostado${endColour} ${yellow}$initial_bet\$${endColour}${gray} y tienes ${endColour}${yellow}$initialMoney$ ${endColour}"
    echo -e "${yellow}[+]${endColour}${gray} Ha salido el numero: ${endColour}${blue}$random_number${endColour}"
    
      if [ "$par_impar" == "par" ]; then
      
        if [ "$(($random_number % 2))" -eq 0 ]; then
          if [ "$random_number" -eq 0 ]; then
            echo -e "${yellow}[!]${endColour}${red} El numero que ha salido es 0, has perdido${endColour}"
            initial_bet=$(($initial_bet * 2))
            echo -e "${yellow}[+]${endColour}${gray} Te quedas en:${endColour}${yellow} $initialMoney$ ${endColour}" 
            echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta es:${endColour}${yellow} $initial_bet$ ${endColour}"
            bad_plays+="$random_number, "
          else
           echo -e "${yellow}[+]${endColour}${green} El numero es par, ganas!${endColour}"
           reward=$(($initial_bet*2))
           echo -e "${yellow}[+]${endColour}${gray} Has ganado:${endColour} ${yellow}$reward$ ${endColour}"
           initialMoney=$(($initialMoney+$reward))
           echo -e "${yellow}[+]${endColour}${gray} Tu dinero ahora es:${endColour} ${yellow}$initialMoney$ ${endColour}"
           if [ "$initialMoney" -gt "$top_money" ];then
            top_money=$initialMoney
           fi
            
            initial_bet=$backup_bet
            bad_plays="[ "
          fi
        else
          echo -e "${yellow}[+]${endColour}${red} El numero es impar, has perdido${endColour}"
          initial_bet=$(($initial_bet * 2))
          echo -e "${yellow}[+]${endColour}${gray} Te quedas en:${endColour}${yellow} $initialMoney$ ${endColour}"
          echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta es:${endColour} ${yellow}$initial_bet$ ${endColour}"
          bad_plays+="$random_number, "
        fi
      else
        if [ "$(($random_number % 2))" -eq 0 ]; then
            echo -e "${yellow}[+]${endColour}${red} El numero es par, has perdido${endColour}"
            initial_bet=$(($initial_bet * 2))
            echo -e "${yellow}[+]${endColour}${gray} Te quedas en:${endColour}${yellow} $initialMoney$ ${endColour}"
            echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta es:${endColour} ${yellow}$initial_bet$ ${endColour}" 
            bad_plays+="$random_number, "
        else
          echo -e "${yellow}[+]${endColour}${green} El numero es impar, ganas!${endColour}"
          reward=$(($initial_bet*2))
          echo -e "${yellow}[+]${endColour}${gray} Has ganado:${endColour} ${yellow}$reward$ ${endColour}"
          initialMoney=$(($initialMoney+$reward))
          echo -e "${yellow}[+]${endColour}${gray} Tu dinero ahora es:${endColour} ${yellow}$initialMoney$ ${endColour}"
          initial_bet=$backup_bet
          bad_plays="[ "
          if [ "$initialMoney" -gt "$top_money" ];then
          top_money=$initialMoney
          fi
          
        fi
      fi
    let play_counter+=1
    sleep 2
  done
  tput cnorm
}  

function inverseLabrouchere(){
  echo -e "\n${yellow}[+]${endColour} ${gray}Su dinero actual es:${endColour} ${yellow}$initialMoney$ ${endColour}\n"

   echo -ne "${yellow}[+]${endColour}${gray} A que quieres apostar continuamente${endColour}${blue}?${endColour} ${blue}(${yellow}par${endColour}${blue}/${endColour}${yellow}impar${endColour}${blue})${endColour} ${red}->${endColour} " && read par_impar 
  
  if [[ ! $par_impar =~ ^(par|impar)$ ]]; then
    echo -e "\n${yellow}[+]${endColour}${red}Seleccione una opcion valida${endColour} ${blue}(${endColour}${yellow}par${endColour}${blue}/${endColour}${yellow}impar${endColour}${blue})${endColour}\n" 
    exit 1
  fi
  
  declare -a sequence=()

  while true; do
    echo -ne "${yellow}[+]${endColour}${gray} Ingrese la secuencia deseada para esta tecnica${endColour} ${blue}(${endColour}${purple}Cuando finalice presione Enter${endColour}${blue})${endColour}${red} -> ${endColour}"&& read input
    
    if [[ -z "$input" ]]; then
      break #Si esta vacio input sale del bucle
    fi
  
    sequence+=("$input")
  done
  
  declare -i checker=0
  declare -i position=1

  for nums in ${sequence[@]}; do
    if [[ ! $nums =~ ^[0-9]+$ ]]; then
      checker=1
      echo -e "\n${red}[!] En la posicion $position ha ingresado un valor erroneo, verifique otras posiciones${endColour} ${turquoise}:(${endColour}"
      break
    fi
    let position+=1
  done

  if [ "$checker" -eq 1 ]; then
    echo -e "\n${yellow}[+]${endColour}${gray} Toda la secuencia debe ser de numeros enteros${endColour}${turquoise} :)${endColour}\n"
    exit 1
  fi
  
  if [ "${#sequence[@]}" -eq 1 ]; then
    echo -e "\n${red}[!] La secuencia debe contener 2 o mas valores, verifique${endColour}${turquoise} :(${endColour}\n"
    exit 1
  fi
  
  initial_bet=$((${sequence[0]} + ${sequence[-1]}))
  backup_sequence=(${sequence[@]})  
  
  #echo -e "\n${yellow}[+]${endColour}${gray} Comenzando la secuencia en: ${endColour}${turquoise}[ ${sequence[@]} ]${endColour}\n"
  
  #actualizando secuencia despues de eliminar valores
  
  echo -e "\n${yellow}[+]${endColour}${gray} Su apuesta inicial es de ${endColour}${yellow}$initial_bet$ ${endColour}${gray}a${endColour}${yellow} $par_impar${endColour}"

  #VARIABLES 
  bad_plays="[ "
  declare -i play_counter=1 
  declare -i backup_money=$initialMoney
  declare -i top_money=$initialMoney
  declare -i earnings=$(($initialMoney + 50))
  
  tput civis
  while true; do
    random_number=$(($RANDOM % 37))
    
    initialMoney=$(($initialMoney - $initial_bet))
    
    if [ "$initialMoney" -lt 0 ]; then
      echo -e "\n${red}[!] Te has quedado sin dinero, no puedes seguir apostando${endColour} ${turquoise}:(${endColour}\n"
      echo -e "${yellow}[+]${endColour}${gray} Han habido un total de ${endColour}${yellow}$play_counter${endColour}${gray} jugadas${endColour}"
      echo -e "${yellow}[+]${endColour}${gray} Se representa en un Array todas las malas jugadas que han salido para perder${endColour}"
      bad_plays_reformed=$(echo $bad_plays | sed "s/,$/ /")
      echo -e "${yellow} ->${endColour}${red} $bad_plays_reformed]${endColour}"
      echo -e "\n${yellow}[+]${endColour}${gray} El maximo ganado antes de perderlo todo es: ${endColour}${yellow}$top_money$ ${endColour}\n"
      tput cnorm; exit 0
    fi

    if [ "${#sequence[@]}" -le 0 ]; then
      sequence=(${backup_sequence[@]})
    fi

    #Aqui si logramos una ganancia de 50 segun la apuesta inicial entonces, reiniciamos la secuencia
    if [ "$initialMoney" -gt "$earnings" ]; then
      #echo -e "${yellow}[+]${endColour}${purple}Se ha reiniciado la secuencia${endColour}"
      sequence=(${backup_sequence[@]})
      earnings=$(($earnings + 50))
      initial_bet=$((${sequence[0]} + ${sequence[-1]})) 
      #echo -e "${yellow}[+]${endColour}${gray} El siguiente tope para reiniciar la secuencia es: ${endColour}${yellow}$earnings$ ${endColour}"
    fi

    if [ "$initialMoney" -le "$(($earnings - 100))" ]; then
      earnings=$(($earnings - 50))
      #echo -e "${yellow}[+]${endColour}${purple} Se ha llegado a un tope critico, se actualizo el maximo de dinero para renovar la secuencia, el nuevo es: ${endColour}${yellow}$earnings$ ${endColour}"
    fi
    
    #echo -e "\n${yellow}[+]${endColour}${gray} Nuestra secuencia actual es: ${endColour}${turquoise}${sequence[@]}${endColour}"
    #echo -e "${yellow}[+]${endColour}${gray} Has apostado ${endColour}${yellow}$initial_bet$ ${endColour}${gray}y tienes${endColour}${yellow} $initialMoney$ ${endColour}"
    #echo -e "${yellow}[+]${endColour}${gray} Ha salido el numero: ${endColour}${blue}$random_number${endColour}"
    
    if [ "$par_impar" == "par" ]; then
      
      if [ $(($random_number % 2)) -eq 0 ] && [ "$random_number" -ne 0 ]; then  

        #echo -e "${yellow}[+]${endColour}${green} Ha salido par, ganas!${endColour}"
        
        reward=$(($initial_bet * 2))
        sequence+=("$initial_bet")
        initialMoney=$(($initialMoney + $reward))
        initial_bet=$((${sequence[0]} + ${sequence[-1]}))

        if [ "$initialMoney" -gt "$top_money" ]; then
          top_money=$initialMoney
        fi
        
        bad_plays="[ "
        #echo -e "${yellow}[+]${endColour}${gray} Quedas con un total de ${endColour}${yellow}$initialMoney$ ${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta es: ${endColour}${yellow}$initial_bet$ ${endColour}"
      
      else

        #if [ "$random_number" -eq 0 ]; then
          #echo -e "${red}[!] Ha salido el numero 0, has perdido${endColour}"
        #else
          #echo -e "${red}[!] Ha salido impar, pierdes!${endColour}" 
        #fi
        #initialMoney=$(($initialMoney - $initial_bet)) 

        if [ "${#sequence[@]}" -eq 1 ]; then
          unset sequence[0]
          
          sequence=(${backup_sequence[@]})
          initial_bet=$((${sequence[0]} + ${sequence[-1]}))
        else

        if [ "${#sequence[@]}" -gt 1 ]; then
          unset sequence[0]
          unset sequence[-1]
          
          sequence=(${sequence[@]})
          
          if [ "${#sequence[@]}" -eq 0 ]; then
            sequence=(${backup_sequence[@]})
          fi
          
          initial_bet=$((${sequence[0]} + ${sequence[-1]}))
          
        fi
        
        if [ "${#sequence[@]}" -eq 1 ]; then
          initial_bet=${sequence[0]}
          
          sequence=(${sequence[@]})
        fi
      fi
          bad_plays+="$random_number, "

          #echo -e "${yellow}[+]${endColour}${gray} Tu dinero actual es de ${endColour}${yellow}$initialMoney$ ${endColour}"
          if [ "$initialMoney" -le 0 ]; then
            initialMoney=-1
            continue
          fi

          #echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta sera: ${endColour}${yellow}$initial_bet$ ${endColour}"
  fi
    else
      if [ $(($random_number % 2)) -eq 1 ]; then

        #echo -e "${yellow}[+]${endColour}${green} Ha salido impar, ganas!${endColour}"
        reward=$(($initial_bet * 2))
        initialMoney=$(($initialMoney + $reward))
        sequence+=("$initial_bet")

        initial_bet=$((${sequence[0]} +  ${sequence[-1]}))
        
        if [ "$initialMoney" -gt "$top_money" ]; then
          top_money=$initialMoney
        fi

        bad_plays="[ "
        #echo -e "${yellow}[+]${endColour}${gray}Tu dinero actual es de: ${endColour}${yellow}$initialMoney$ ${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta sera: ${endColour}${yellow}$initial_bet$ ${endColour}"
      else
        #echo -e "${red}[!] Ha salido par, pierdes!${endColour}"
        #initialMoney=$(($initialMoney - $initial_bet))
        
        unset sequence[0]
        unset sequence[-1] 2>/dev/null
        
        sequence=(${sequence[@]})
        
        if [ "${#sequence[@]}" -le 0 ]; then
          sequence=(${backup_sequence[@]})
          initial_bet=$((${sequence[0]} + ${sequence[-1]}))
        elif [ "${#sequence[@]}" -eq 1 ]; then
          initial_bet=${sequence[0]}
        else
          initial_bet=$((${sequence[0]} + ${sequence[-1]}))
        fi
        
        bad_plays+="$random_number, "
        
        #echo -e "${yellow}[+]${endColour}${gray} Tu dinero actual queda en ${endColour}${yellow}$initialMoney$ ${endColour}"
        if [ "$initialMoney" -le 0 ]; then
          initialMoney=-1
          continue
        fi

        #echo -e "${yellow}[+]${endColour}${gray} La siquiente apuesta sera: ${endColour}${yellow}$initial_bet$ ${endColour}"
      fi
    fi
  let play_counter+=1
  #sleep 2
  done
  tput cnorm
}

function fibonacci(){
  echo -e "\n${yellow}[+]${endColour}${gray} Has seleccionado la tecnica ${endColour}${blue}Fibonacci${endColour}"
 
  echo -ne "${yellow}[+]${endColour}${gray} A que quieres apostar continuamente${endColour}${blue}?${endColour} ${blue}(${yellow}par${endColour}${blue}/${endColour}${yellow}impar${endColour}${blue})${endColour} ${red}->${endColour} " && read par_impar 
  
  if [[ ! $par_impar =~ ^(par|impar)$ ]]; then
    echo -e "\n${yellow}[+]${endColour}${red}Seleccione una opcion valida${endColour} ${blue}(${endColour}${yellow}par${endColour}${blue}/${endColour}${yellow}impar${endColour}${blue})${endColour}\n" 
    exit 1
  fi 

  echo -e "\n${yellow}[+]${endColour}${gray} Su dinero inicial es de: ${endColour}${yellow}$initialMoney$ ${endColour}${gray}y aposto a ${endColour}${yellow}$par_impar ${endColour}"
  
  declare -a sequence=(0)
  bad_plays="[ "
  declare -i play_counter=1
  declare -i top_money=$initialMoney
  declare -i bet=0

  bet=1
  sequence+=("$bet")

  tput civis
  while true; do
    
    random_number=$(($RANDOM % 37))
    initialMoney=$(($initialMoney - $bet))

    if [ "$initialMoney" -lt 0 ]; then
      echo -e "\n${red}[!] Te has quedado sin dinero, no puedes seguir apostando${endColour} ${turquoise}:(${endColour}\n"
      echo -e "${yellow}[+]${endColour}${gray} Han habido un total de ${endColour}${yellow}$play_counter${endColour}${gray} jugadas${endColour}"
      echo -e "${yellow}[+]${endColour}${gray} Se representa en un Array todas las malas jugadas que han salido para perder${endColour}"
      bad_plays_reformed=$(echo $bad_plays | sed "s/,$/ /")
      echo -e "${yellow} ->${endColour}${red} $bad_plays_reformed]${endColour}"
      echo -e "\n${yellow}[+]${endColour}${gray} El maximo ganado antes de perderlo todo es: ${endColour}${yellow}$top_money$ ${endColour}\n"
      tput cnorm; exit 0
    fi


    #echo -e "\n${yellow}[+]${endColour}${gray} Ha salido el numero${endColour}${yellow} $random_number ${endColour}"
    #echo -e "${yellow}[+]${endColour}${gray} Has apostado ${endColour}${yellow}$bet$ ${endColour}${gray}y tienes${yellow} $initialMoney$ ${endColour}"

    if [ "$par_impar" == "par" ]; then
      
      if [ $((random_number % 2)) -eq 0 ] && [ "$random_number" -ne 0 ]; then
        #echo -e "${yellow}[+]${endColour}${green} El numero es par asi que ganas${endColour}"
        
        reward=$(($bet * 2))
        initialMoney=$(($initialMoney + $reward))

        if [ "${#sequence[@]}" -le 3 ]; then
          bet=1
          sequence=(0 1)
        else
          #echo -e "${yellow}[+]${endColour}${gray} Se han eliminan los elementos posteriores :)${endColour}"
          for i in $(seq $((${#sequence[@]} - 2)) $((${#sequence[@]} - 1 )) ); do
            #echo "Valor $i"
            unset sequence[$i] 2>/dev/null
          done
          sequence=(${sequence[@]})
          bet=${sequence[-1]}
        
        fi
       
        bad_plays="[ "

        if [ "$initialMoney" -gt "$top_money" ]; then
          top_money=$initialMoney
        fi

        #echo -e "${yellow}[+]${endColour}${gray} La secuencia quedo en: ${endColour}${turquoise}[ ${sequence[@]} ]${endColour}"

        #echo -e "${yellow}[+]${endColour}${gray} Tu dinero queda en: ${endColour}${yellow}$initialMoney$ ${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta sera ${endColour}${yellow}$bet$ ${endColour}"
      else
        
        #if [ "$random_number" -eq 0 ]; then
          #echo -e "${red}[!] Ha salido 0, perdiste!${endColour}"
        #else
          #echo -e "${red}[!] Ha salido un numero impar, perdiste!${endColour}"
        #fi

        first_before_value=${sequence[$((${#sequence[@]} - 1))]}
        second_before_value=${sequence[$((${#sequence[@]} - 2))]}

        bet=$(($first_before_value + $second_before_value))
        sequence+=("$bet")
        
        bad_plays+="$random_number, "

        #echo -e "${yellow}[+]${endColour}${gray} La secuencia queda asi ${endColour}${turquoise}[ ${sequence[@]} ]${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} Los valores anteriores son: ${endColour}${blue}$first_before_value | $second_before_value${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta es: ${endColour}${yellow}$bet$ ${endColour}"
      fi

    else
      if [ $((random_number % 2)) -eq 1 ]; then
        #echo -e "${yellow}[+]${endColour}${green} Ha salido impar, ganas :)${endColour}"
        
        reward=$(($bet * 2))
        initialMoney=$(($initialMoney + $reward))

        if [ "${#sequence[@]}" -le 3 ]; then
          bet=1
          sequence=(0 1)
        else
          #echo -e "${yellow}[+]${endColour}${red} Se han eliminan los elementos posteriores :)${endColour}"
          for i in $(seq $((${#sequence[@]} - 2)) $((${#sequence[@]} - 1 )) ); do
            #echo "Valor $i"
            unset sequence[$i] 2>/dev/null
          done
          sequence=(${sequence[@]})
          bet=${sequence[-1]}
        
        fi
       
        bad_plays="[ "

        if [ "$initialMoney" -gt "$top_money" ]; then
          top_money=$initialMoney
        fi

        #echo -e "${yellow}[+]${endColour}${gray} La secuencia quedo en: ${endColour}${turquoise}[ ${sequence[@]} ]${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} Tu dinero queda en: ${endColour}${yellow}$initialMoney$ ${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta sera ${endColour}${yellow}$bet$ ${endColour}"

      else
        #echo -e "${red}[!] Ha salido par, has perdido :(${endColour}"
        
        first_before_value=${sequence[$((${#sequence[@]} - 1))]}
        second_before_value=${sequence[$((${#sequence[@]} - 2))]}

        bet=$(($first_before_value + $second_before_value))
        sequence+=("$bet")

        bad_plays+="$random_number, "

        #echo -e "${yellow}[+]${endColour}${gray} La secuencia queda asi ${endColour}${turquoise}[ ${sequence[@]} ]${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} Los valores anteriores son: ${endColour}${blue}$first_before_value | $second_before_value${endColour}"
        #echo -e "${yellow}[+]${endColour}${gray} La siguiente apuesta es: ${endColour}${yellow}$bet$ ${endColour}"

      fi
    fi

    let play_counter+=1
    #sleep 4
  done
  tput cnorm
}

declare -i parameter_counter=0

while getopts "m:t:h" args; do 
  case $args in
    m) initialMoney=$OPTARG; let parameter_counter+=1;;
    t) technique=$OPTARG; let parameter_counter+=2;;
    h) ;;
  esac 
done

if [ $parameter_counter -eq 3 ]; then  
  if [ "$technique" == "martingala" ]; then
    martingala
  elif [ "$technique" == "inverseLabrouchere" ] || [ "$technique" == "il" ]; then
    inverseLabrouchere
  elif [ "$technique" == "fibonacci" ]; then
    fibonacci
  else
    echo -e "\n${red}[!] Has seleccionado una tecnica que no existe${endColour}"
    helpPanel
  fi
else
  helpPanel
fi

