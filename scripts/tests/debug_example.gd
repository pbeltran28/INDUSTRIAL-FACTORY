## debug_example.gd — Guía 13: Debugging con breakpoints
## Pon un breakpoint en la línea marcada y observa variables en el panel Debugger
extends Node

func _ready()->void:
	print("=== Guía 13: Debug Example ===")
	for n in [2,3,4,7,11,15,17,25,31]:
		var r=is_prime(n)
		print("is_prime(%d) = %s"%[n,r]) # ← BREAKPOINT AQUÍ

func is_prime(n:int)->bool:
	if n<2: return false
	if n==2: return true
	if n%2==0: return false
	var i=3
	while i*i<=n:
		if n%i==0: return false
		i+=2
	return true

func get_divisors(n:int)->Array:
	var result=[]
	for i in range(1,n+1):
		if n%i==0: result.append(i)  # ← BREAKPOINT AQUÍ para inspeccionar
	return result
