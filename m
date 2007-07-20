From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 20 Jul 2007 05:00:03 +0000
Subject: Re: iperf
Message-Id: <5640c7e00707192200j8e29817l4bba86b02e9ccc6f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/20/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> I agree. I think only thing missing from Gerrit's is my continuous
> patch which should apply on top of his I'm guessing.
>
> I might just go do some iperf hacking now and see what I can find...
>
> Ian

OK. I've hacked my iperf version around a bit to get closer to Gerrit's.

What I've done:
- ported more of his code over
-- renaming/shifting code
-- fix service code handling to allow network byte order and correct name
-- merged using -b option for DCCP (NB gives an error at end but seems
to be working OK)

Our code still differs a bit e.g. I don't support UDP Lite yet.

So if you want unlimited run time and -b together then you want my
tree, otherwise Gerrit's is probably better. I'm sure Gerrit can port
my unlimited run time easily to his tree if he wants.

My patches are at:
http://wand.net.nz/~iam4/iperf/

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
