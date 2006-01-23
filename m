From: h.balan@iu-bremen.de
Date: Mon, 23 Jan 2006 20:13:15 +0000
Subject: [Fwd: Re: loss detection and tfrc rate]
Message-Id: <65209.84.56.242.24.1138047195.squirrel@mail2web.iu-bremen.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org


It=B4s the net-2.6 version from Dave Miller=B4s git at kernel.org (from a w=
eek
or so ago, quite similar to 2.6.14). If this is not the ultimate source
for it, I would appreciate a pointer in the right direction.

Vlad

> On 1/24/06, h.balan@iu-bremen.de <h.balan@iu-bremen.de> wrote:
>>
>> I was using DCCP over a very lossy setup (more than 10% losses in each
>> direction) and I could not get the kernel to stop in the detect_loss()
>> function (using UML and setting breakpoints). I inserted a printk() in
>> dccp_li_hist_calc_i_mean() which should be called by all TFRC rate
>> calculations, but, according to the logs, this function is not called
>> either.
>> I would appreciate if someone could check this again, since there
>> are people on the list much more familiar with the implementation.
>>
>> My second question regards the loss intervals used by TFRC. In one of
>> the
>> defining documents it is mentioned that a loss interval should be at
>> least
>> one measured RTT long, however I could not see where this is implemented
>> in the source code. Could someone help me here?
>>
> Where have you obtained DCCP from and what version are you running?
>
> Ian
> --
> Ian McDonald
> http://wand.net.nz/~iam4
> WAND Network Research Group
> University of Waikato
> New Zealand
>



