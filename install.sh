#!/bin/bash
GIT_ROOT="$(git rev-parse --show-toplevel)"
SRC="$GIT_ROOT/src"
FS_CHROME="$SRC/chrome"
FS_ICONS="$SRC/icons"
FS_USR_PREFS="$SRC/user.js"
FS_JSON="$GIT_ROOT/fireswag.json"

# STATUS PROMPTS
I_SUCCESS="${RESET}[ ${C_GREEN}SUCCESS${C_RESET} ]" 
I_ERROR="${RESET}[ ${C_RED}ERROR${C_RESET} ]"
I_SKIP="${RESET}[ ${C_CYAN}SKIPPED${C_RESET} ]"
I_PROCESSING="${RESET}[ ${C_CYAN}PROCESSING ..${C_RESET} ]"
I_MANUALLY="${C_RESET}[ ${C_YELLOW}MANUALLY${C_RESET} ]"
I_ASK="${C_RESET}[ ${C_BLUE}???${C_RESET} ]"
I_ASK_YN="${C_RESET}[ ${C_BLUE}y/n${C_RESET} ]"
I_INFO="${C_RESET}[ ${C_PURPLE}INFO${C_RESET} ]"

done_init=false
done_dependencies=false
done_userchrome=false
done_icons=false
done_userprefs=false

ff_directories="" # set by dependencies function after jq (dependency) is ensured

init() {
  printf "${I_MANUALLY} To customize FireSwag installation, check fireswag.json \n"
  printf "${I_ASK_YN} Have you checked fireswag.json and are you ready to go? \n"
  read usr_continue  
  if [[ "$usr_continue" == "y" || "$usr_continue" == "Y" ]]; then
    done_init=true # value that toggles function execution
  else
    done_init=false
    printf "${I_ERROR} Cancelling FireSwag installation. \n" 
    exit 1
  fi
}

dependencies() {
  # Check if jq is installed
  if command -v jq &> /dev/null; then
    ff_directory=$(jq -r '.ff_directory' "$FS_JSON") # read json
    printf "${I_INFO} Applying options from fireswag.json \n"
    done_dependencies=true
  else
    printf "${I_ERROR} jq is not installed. Please install and re-run script. \n"
    done_dependencies=false
    exit 1
  fi

    printf "inside dependencies function: \n $ff_directory \n"
}

userchrome() {
  printf "${I_INFO} Installing FireSwag to $ff_directory \n"
  # overwrite chrome dir
  if [[ -d "$ff_directory/chrome" ]]; then
    rm -rf "$ff_directory/chrome"
  fi
  cp -R "$FS_CHROME" "$ff_directory"
  printf "${I_SUCCESS} FireSwag installed to $ff_directory \n"
  done_userchrome=true
}

icons() {
  # overwrite icons dir
  if [[ -d "$ff_directory/icons" ]]; then
    rm -rf "$ff_directory/icons"
  fi
  cp -R "$FS_ICONS" "$ff_directory"
  printf "${I_SUCCESS} FireSwag icons set \n"
  done_icons=true
}

userprefs() {
  # overwrite userprefs file 
  if [[ -f "$ff_directory/user.js" ]]; then
    rm "$ff_directory/user.js"
  fi
  cp -R "$FS_USR_PREFS" "$ff_directory"
  printf "${I_SUCCESS} FireSwag preferences set \n"
  done_userprefs=true
}

call_functions(){
  # call function dependencies
  if [[ "$done_init" == true ]]; then
    done_init=false
    dependencies
  else 
    printf "${I_ERROR} Cancelling FireSwag installation. \n" 
    exit 1
  fi
  
  # call function userchrome only if dependencies were successful
  if [[ "$done_dependencies" == true ]]; then
    done_dependencies=false
    userchrome
  else 
    printf "${I_ERROR} Cancelling FireSwag installation. \n" 
    exit 1
  fi
  
  # call function icons only if userchrome was successful
  if [[ "$done_userchrome" == true ]]; then
    done_userchrome=false
    icons 
  else 
    printf "${I_ERROR} Cancelling FireSwag installation. \n" 
    exit 1
  fi
  
  # call function userprefs only if icons were successful
  if [[ "$done_icons" == true ]]; then
    done_icons=false
    userprefs
  else 
    printf "${I_ERROR} Cancelling FireSwag installation. \n" 
    exit 1
  fi
}

init
call_functions
