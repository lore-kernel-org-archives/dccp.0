From: Ian McDonald <imcdnzl@gmail.com>
Date: Mon, 23 Jan 2006 19:33:21 +0000
Subject: Re: loss detection and tfrc rate
Message-Id: <cbec11ac0601231133m5c645c1epb7dd2842490ec136@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <64065.84.56.242.24.1138041574.squirrel@mail2web.iu-bremen.de>
In-Reply-To: <64065.84.56.242.24.1138041574.squirrel@mail2web.iu-bremen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/24/06, h.balan@iu-bremen.de <h.balan@iu-bremen.de> wrote:
>
> I was using DCCP over a very lossy setup (more than 10% losses in each
> direction) and I could not get the kernel to stop in the detect_loss()
> function (using UML and setting breakpoints). I inserted a printk() in
> dccp_li_hist_calc_i_mean() which should be called by all TFRC rate
> calculations, but, according to the logs, this function is not called
> either.
> I would appreciate if someone could check this again, since there
> are people on the list much more familiar with the implementation.
>
> My second question regards the loss intervals used by TFRC. In one of the
> defining documents it is mentioned that a loss interval should be at least
> one measured RTT long, however I could not see where this is implemented
> in the source code. Could someone help me here?
>
Where have you obtained DCCP from and what version are you running?

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
