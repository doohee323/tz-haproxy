This is a haproxy example on vagrant.
==========================================================================

# Features
	1. make 4 nodes (nodehome1, nodehome2, node1, node2) 
	2. install haproxy and keepalive on nodehome1, nodehome2
	3. install ngnix on node1, node2 
	4. test nginx with haproxy
	5. test nginx with haproxy and keepalive

# Execution
```
	vagrant up
	#vagrant destroy -f && vagrant up
```

# Running process
```
	- on nodehome1
		: haproxy
		http://192.168.82.170:8080
		
	- on node1, node2
		: keepalive and ngnix
			http://192.168.82.172:80
			http://192.168.82.173:80
```

# Haproxy Test
```
<<<<<<< Upstream, based on e54e45d869f74efb4839f6d63f4e982afcd1f49c
<<<<<<< Upstream, based on e54e45d869f74efb4839f6d63f4e982afcd1f49c
	- on nodehome1 or outside of VMs
		vagrant ssh nodehome1
		curl http://192.168.82.170:8080
		sudo tail -f /var/log/haproxy.log

=======
	- on nodehome or outside of VMs
		vagrant ssh nodehome
		vagrant@nodehome:~$ curl http://192.168.82.170:8080
		vagrant@nodehome:~$ sudo tail -f /var/log/haproxy.log
		
>>>>>>> 0872f57 upgrade ubuntu 16.04
=======
	- on nodehome1 or outside of VMs
		vagrant ssh nodehome1
		curl http://192.168.82.170:8080
		sudo tail -f /var/log/haproxy.log

>>>>>>> 7cae868 add keepalive on both nodehome1 and nodehome2
	- Monitoring
	  http://192.168.82.170:9000/haproxy_stats
	  admin1 / password2
	
	- logging on node1, node2
		vagrant ssh node1
		vagrant@node1:/var/log/nginx$ 
		
		sudo tail -f /var/log/nginx/access.log
		sudo nginx -s stop
		sudo nginx
		
		vagrant ssh node2
		vagrant@node2:/var/log/nginx$ 
		
		sudo tail -f /var/log/nginx/access.log
		
	- Test service
<<<<<<< Upstream, based on e54e45d869f74efb4839f6d63f4e982afcd1f49c
<<<<<<< Upstream, based on e54e45d869f74efb4839f6d63f4e982afcd1f49c
	  curl http://192.168.82.172:80
	  curl http://192.168.82.173:80
=======
	  curl http://192.168.82.171:80
=======
>>>>>>> 7cae868 add keepalive on both nodehome1 and nodehome2
	  curl http://192.168.82.172:80
<<<<<<< Upstream, based on e54e45d869f74efb4839f6d63f4e982afcd1f49c
>>>>>>> 0872f57 upgrade ubuntu 16.04
=======
	  curl http://192.168.82.173:80
>>>>>>> 7cae868 add keepalive on both nodehome1 and nodehome2
	  =>
	  curl http://192.168.82.170:8080
```

# Keepalive Test
```
	- kill haproxy on nodehome1
		vagrant ssh nodehome1
		service haproxy stop
		service haproxy status

		curl http://192.168.82.174:8080/

	- kill haproxy on nodehome2
		vagrant ssh nodehome2
		service haproxy stop
		service haproxy status

		curl http://192.168.82.174:8080/

	- start haproxy on nodehome1
		vagrant ssh nodehome1
		service haproxy start
		service haproxy status

		curl http://192.168.82.174:8080/
```


