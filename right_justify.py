import math

def right_justify(name):
    mul=70-len(name)
    print((' '*mul)+name)

right_justify('ashish')
right_justify('ashish kishore')
right_justify('ashish kishore sinha')


def prime_numbers(n):
    cnt = 0
    for i in range(1,n+1):
        for j in range(2,i):
            if i % j == 0:
                cnt = cnt+1
        if cnt == 0:
            print(i)
        cnt=0


prime_numbers(5)

def triangle_check(a,b,c):
    if (a+b>c) and (b+c>a) and (c+a>b):
        print ('Valid sides.\nTriangle can be formed.')
    else:
        print('Invalid Sides.\nTriangle can not be formed.')


triangle_check(2,3,6)

def distance(xc,yc,xp,yp):
    return math.sqrt(((xp-xc)**2)+((yp-yc)**2))

print('the pie value ={}'.format(math.pi))

def area (radius):
    return math.pi*(radius**2)

def get_radius_and_area():
    xc = int(input('Enter the x coordinate of first point: '))
    yc = int(input('Enter the y coordinate of first point: '))
    xp = int(input('Enter the x coordinate of second point: '))
    yp = int(input('Enter the y coordinate of second point: '))
    radius = distance(xc,yc,xp,yp)
    print('Radius of circle is {}'.format(radius))
    area_of_circle = area(radius)
    print('Area of circle is {}'.format(area_of_circle))
    return 'process completed.'

#get_radius_and_area()

def factorial(n):
    if n==0:
        return 1
    else:
        recurse=factorial(n-1)
        result=n*recurse
        return result

print('Factorial of {0} is {1}'.format(5,factorial(5)))

def first(word):
    return word[0]

def last(word):
    return word[-1]

def middle(word):
    return word[1:-1]

#palindrome('assa')

name='JKLMNOPQ'
suffix='ack'

#for letter in name:
#    if letter=='O' or letter=='Q':
#        print(letter+'uack')
#    else:
#        print(letter+suffix)

#print('banana'.count('a'))

def in_both(word1,word2):
    for letter in word1:
        if letter in word2:
            print (letter)

#in_both('ashish','abc')


def code_13(sentence):
    coded=''
    for letter in sentence:
        coded=coded+chr(ord(letter)+13)
    return coded


def decode_13(sentence):
    decoded=''
    for letter in sentence:
        decoded=decoded+chr(ord(letter)-13)
    return decoded

sentence='Hi Hasin Bhai.. Lets meet 5PM today'
coded=code_13(sentence)
print(coded)
decoded=decode_13(coded)
print(decoded)

fin=open('Test.txt','r')
content=fin.read()
print(content)


# Create a file if not exist
f=open('ashish_py.txt','w+')
for i in range(11):
     f.write('This is line number %d\r\n'%(i+1))
f.close()

def count_substring(string, sub_string):
    cnt=0
    j=len(sub_string)
    for i in range(0,len(string)):
        sub=string[i:i+j]
        if sub==sub_string:
            cnt=cnt+1
    return cnt


if __name__ == '__main__1':
    s = input('Enter Text :\n')
    print (any(c.isalnum() for c in s))
    print (any(c.isalpha() for c in s))
    print (any(c.isdigit() for c in s))
    print (any(c.islower() for c in s))
    print (any(c.isupper() for c in s))

name ='abhilasha'
print("\n".join(name[i:i+3] for i in range(0,len(name),3)))

a='-'
b='|'
c='.'
pattern=[('.|.'*(2*i+1)).center(21,'-') for i in range(7//2)]
print('\n'.join(pattern))
print('welcome'.center(21,a))
print('\n'.join(pattern[::-1]))



#f=open('abhilasha.txt','w+')
#n=int(input('N: '))
#m=int(input('M: '))
#pattern = [('.|.'*(2*i + 1)).center(m, '-') for i in range(n//2)]
#f.write('\n'.join(pattern + ['WELCOME'.center(m, '-')] + pattern[::-1]))
#f.close()


def palindrome(word):
    i=0
    j=len(word)-1
    while i<j:
        if word[i]!=word[j]:
            print('{} is not Palindrome'.format(word))
            break
        i=+1
        j=-1
    if i>=j:
        print('{} is Palindrome'.format(word))

palindrome('madam')

#f = open('abhilasha.txt','r')
#for line in f:
#    print(line)

'''f=open('ashish_py.txt','r')
for line in f:
    word=line.split(' ')
    for i in word:
        print(i)
f.close()'''


def fibonacci(a,b,c):
    res=[a]
    for i in range(1, c):
        total = a+b
        res.append(total)
        a = b
        b = total
    print(res)

fibonacci(0,1,22)





i=range(1,10)
for n in i:
    print(n)
