From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Jul 2006 20:46:53 +0000
Subject: Re: Help: how to get the latest code?
Message-Id: <5640c7e00607251346r4d4eb9a3l559c4bde249e3353@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
In-Reply-To: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/26/06, Ma Lin <gavin.malin@gmail.com> wrote:
> Hi Folks,
>
> Can I get it from a CVS server or something like that?
> I have kernel 2.6.15-1 installed, and realized that the code of DCCP
> might be outdated already.
> Thank you :)
>
> malin

Ma Lin,

You are correct in that it is out of date.

Go get a kernel from http://kernel.org - the later the version the
better - at a bare minimum get 2.6.17.x

Git trees are good also if you plan to do development on DCCP - these
are at http://kernel.org.git and I would recommend Linus' tree or Dave
M's tree depending on what you are doing.

If you are planning to do development or find bugs then fire a message
off to this list before you get too carried away as the developers are
quite aware of the bugs around and can help you or cheer you on if you
want to write code. You might also want to look at the archives of
this list as there are a lot of unmerged patches - in particular
Andrea Bittau has written a lot of CCID2 patches to improve that.

Also have a look at:
http://linux-net.osdl.org/index.php/DCCP

Regards,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
