From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 19 Jul 2007 23:39:22 +0000
Subject: Re: iperf
Message-Id: <5640c7e00707191639j76208308ufa2097dcd6f22696@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/20/07, Patrick <patrick.andrieux@gmail.com> wrote:
> Applying only patch #1 doesn't work... patch #2 correct the error.
> PerfSocket.cpp: In function 'void MakeSocket(thread_Settings*)':
> PerfSocket.cpp:89: error: 'IPPROTO_UDPLITE' was not declared in this scope
> make[2]: *** [PerfSocket.o] Error 1
> make[2]: Leaving directory `/root/iperf-2.0.2/src'
> make[1]: *** [all-recursive] Error 1
> make[1]: Leaving directory `/root/iperf-2.0.2'
> make: *** [all] Error 2
>
> It could be good to not have 2 iperf dccp patched version, one Ian
> patched, one Gerrit patched ?
>
I agree. I think only thing missing from Gerrit's is my continuous
patch which should apply on top of his I'm guessing.

I might just go do some iperf hacking now and see what I can find...

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
