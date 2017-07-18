;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	ha.com. root.ha.com. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ha.com.
@	IN	A	192.168.1.200
node0	IN	A	192.168.1.200
node1	IN	A	192.168.1.201
node2	IN	A	192.168.1.202
node3	IN	A	192.168.1.203
node4	IN	A	192.168.1.204
node5	IN	A	192.168.1.205
