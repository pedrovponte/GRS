### Fix Dns network when Vma does not ping


- Check Network using
    - ping google.com
    - dig google.com

- change file
    - nano /etc/resolv.conf

- Change ip
    - 127.0.0.93 -> 1.1.1.1 or 193.136.28.10