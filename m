From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 29 Nov 2006 22:57:25 +0000
Subject: Re: [PATCH RFC] SELinux support for DCCP
Message-Id: <200611292257.25284@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
In-Reply-To: <XMMS.LNX.4.64.0611110203540.25507@d.namei>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Btw, I couldn't find anything to test DCCPv6 with (GNU netcat somehow 
|  lacks IPv6 support), so wrote some simple apps to do this:

I have finally managed to put my ttcp clone also online. It supports DCCPv6 and has
some extra routines to parse service codes, as well as a more verbose reporting of
system errors (i.e. it says "you got a ENOTCONN" instead of "this machine is not connected".
The archive is on
    
     http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/ttcp_dccp.tar.gz

Great to see the SELinux patch.
