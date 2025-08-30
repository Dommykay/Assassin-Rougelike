-- Extra math things that nor lua or the math module have

_G.ROOT2 = math.sqrt(2)

-- I dont actually know how hard it is for a computer to calculate sin but whatever here it is so it doesnt have to do it a ton of times every frame
_G.SIN45 = math.sin(45)


function xor(num1,num2)
    return (num1 or num2) and not (num1 and num2)
end


function pythagorean(givenvector)
    local num1,num2 = givenvector:unpack()
    return math.sqrt(num1^2+num2^2)
end