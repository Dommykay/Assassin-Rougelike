-- Extra math things that nor lua or the math module have

_G.ROOT2 = math.sqrt(2)


function xor(num1,num2)
    return (num1 or num2) and not (num1 and num2)
end


function pythagorean(num1,num2)
    return math.sqrt(num1^2+num2^2)
end