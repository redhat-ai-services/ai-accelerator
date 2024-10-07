print_error(){
  echo -e "\e[31m$1\e[0m" >&2
}

print_warning() {
  echo -e "\e[33m$1\e[0m"
}
