a = int(input())

def min_hours(num):
    hours = str(num // 60) 
    minutes = str(num % 60)
    
    output = "{} hrs {} minutes".format(hours, minutes)
    
    return output

print(min_hours(a))
