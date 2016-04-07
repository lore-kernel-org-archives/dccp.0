From: Vishnu Pratap Singh <vishu13285@gmail.com>
Date: Thu, 07 Apr 2016 17:43:33 +0000
Subject: How to get creatior PID information for the local tcp connection
Message-Id: <CADCeU4NfNucPCqemSxr4SsMUgdOhxzM41zjsRDKfrhsFyMH0+Q@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,


Issue -  How to get PID information for the local tcp connection



i want to get the creator PID for each socket in user space for local
tcp connection, i see in kernel there is support for returing PID with
"SO_PEERCRED" ioctl to work across namespaces. it uses struct pid and
struct cred to store the peer credentials on struct sock.
cred_to_ucred(sk->sk_peer_pid, sk->sk_peer_cred, &peercred); Above
function stores the PID information in ucred->pid = pid_vnr(pid); and
same is returned via "SO_PEERCRED" ioctl .

But for local tcp connection i get pid as 0, is there any way i can
get the PID information. Any help or suggestion will be highly
helpful.



BR,

Vishnu<div id="DDB4FAA8-2DD7-40BB-A1B8-4E2AA1F9FDF2"><br />
<table style="border-top: 1px solid #aaabb6;">
	<tr>
        <td style="width: 55px; padding-top: 13px;"><a
href="https://www.avast.com/sig-email?utm_medium=email&utm_source=link&utm_campaign=sig-email&utm_content=webmail"
target="_blank"><img
src="https://ipmcdn.avast.com/images/2016/icons/icon-envelope-open-tick-round-orange-v1.png"
/></a></td>
		<td style="width: 470px; padding-top: 15px; color: #41424e;
font-size: 13px; font-family: Arial, Helvetica, sans-serif;
line-height: 18px;">Virus-free. <a
href="https://www.avast.com/sig-email?utm_medium=email&utm_source=link&utm_campaign=sig-email&utm_content=webmail"
target="_blank" style="color: #4453ea;">www.avast.com</a>
		</td>
	</tr>
</table><a href="#DDB4FAA8-2DD7-40BB-A1B8-4E2AA1F9FDF2" width="1"
height="1"></a></div>
