This is a haproxy example on vagrant.
==========================================================================

# Features
	1. make 3 nodes (nodehome, node1, node2) 
	2. install keepalive and ngnix on node1, node2 
	3. install haproxy on nodehome
	4. test nginx service

# Execution
```
	vagrant up
	#vagrant destroy -f && vagrant up
```

# Running process
```
	- on nodehome
		: haproxy
		http://192.168.82.170:80
		
	- on node1, node2
		: keepalive and ngnix
			http://192.168.82.171:80
			http://192.168.82.172:80
```

# Test
```
	- on nodehome or outside of VMs
		vagrant ssh nodehome
		vagrant@nodehome:~$ curl http://192.168.82.170:8080
		vagrant@nodehome:~$ sudo tail -f /var/log/haproxy.log
		
		http://192.168.82.170:9000/haproxy_stats
		admin / passwordhere
	
	- logging on node1, node2
		vagrant ssh node1
		vagrant@node1:/var/log/nginx$ 
		
		sudo tail -f /var/log/nginx/access.log
		sudo nginx -s stop
		sudo nginx
		sudo service keepalived stop
		sudo service keepalived start
		
		sudo tail -f /var/log/keepalived.log
		
		vagrant ssh node2
		vagrant@node2:/var/log/nginx$ 
		
		sudo tail -f /var/log/nginx/access.log
		
```




