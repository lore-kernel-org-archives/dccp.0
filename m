From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Mon, 30 Aug 2010 17:33:38 +0000
Subject: Re: DCCP_BUG called
Message-Id: <AANLkTimobXLZX+LDEeEQjyRYZAZvzkoz+xTCkzT8O0S=@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
In-Reply-To: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 26 August 2010 21:12, Eugen Dedu <Eugen.Dedu@pu-pm.univ-fcomte.fr> wrote:
> We have a working environment, but maybe there is some useful stuff in your scripts, send them to us if it does not take you much time.
>
> Thank you,
> Eugen
>

To turn rate limiting and delay on I do:
/sbin/tc qdisc add dev lan0 root handle 1:0 netem delay $1ms
/sbin/tc qdisc add dev lan1 root handle 1:0 netem delay $1ms
/sbin/tc qdisc add dev lan0 parent 1:1 handle 10: tbf rate $2kbit
buffer 10000 limit 30000

and off:
/sbin/tc qdisc del dev lan0 parent 1:1
/sbin/tc qdisc del dev lan0 root
/sbin/tc qdisc del dev lan1 root

To turn on packet loss and delay I do:
/sbin/tc qdisc add dev lan1 root netem delay $1ms loss $3%
/sbin/tc qdisc add dev lan0 root netem delay $1ms loss $2%

and off:
/sbin/tc qdisc del dev lan1 root netem
/sbin/tc qdisc del dev lan0 root netem

These are all from the box in the middle.

Regards

Ian
