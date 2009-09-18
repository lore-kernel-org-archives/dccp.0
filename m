From: gerrit@erg.abdn.ac.uk
Date: Fri, 18 Sep 2009 22:54:53 +0000
Subject: Re: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <5006.72.11.80.242.1253314493.squirrel@72.11.80.242>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
In-Reply-To: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorry for the delay in replying.

>> One future patch will need to modify this file, but now it's really an
>> exact copy.
>>
>>
> Basically the rule with a patch set is that all the patches should
> make sense together.
>
> It may well be that it makes sense to make a copy, but if you want to
> do this then present it with the patch that then modifies it.
>
I agree with Ian's point. At the moment I can only see patch 5/5 modifying
this file (adding documentation); from my reading of RFC 4828/5622 it seems
not necessary to use 'tfrc_sp' variants of the functions computing X.

The situation will be better as soon as the patches are in their own subtree.
Currently there is a benefit in using separate files: the tfrc library does
not support a sender-based variant of TFRC, hence requires further work
and/or
a decision to support a sender-bsed variant of CCID-3/4 only in an
experimental subtree - this requires input and discussion.

