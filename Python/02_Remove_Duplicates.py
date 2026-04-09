a = input()
def remove_duplicats(a) :
    s = ""
    for i in a:
        if i in s:
            continue
        else:
            s += i 
    return s 
print(remove_duplicats(a))