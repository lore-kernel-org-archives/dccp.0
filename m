From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 26 Oct 2006 01:02:33 +0000
Subject: Re: mmap
Message-Id: <20061026010233.GA28679@c3po.0xdef.net>
List-Id: <dccp.vger.kernel.org>
References: <92b224de0610251748j1bb6f094q4099d47e236ecd8@mail.gmail.com>
In-Reply-To: <92b224de0610251748j1bb6f094q4099d47e236ecd8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

* Sudharsan Rangarajan | 2006-10-25 17:48:41 [-0700]:

>Hi everyone,
>I would like to look at the mmap implementation for dccp.  I looked at
>http://wlug.org.nz/DCCP to get the source, but cant seem to find it!
>Can someone please help?

DCCP-Sockets implement no mmap operations, ENODEV is returned if you use it!

Take a look at you kernel-sources for dccp implementation details:
e.g. /usr/src/linux-2.6/net/dccp/*

>Thanks,
>Sudharsan

HGN


-- 
In the manual it said: 'For use with Windows95, 98, or better.' So I 
installed LINUX...
unbekannter User
