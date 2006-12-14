From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Dec 2006 14:34:24 +0000
Subject: 48-bit sequence arithmetic: proposed changes
Message-Id: <200612141434.24458@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Below is a write-up of some issues that I found with the sequence number arithmetic.
This is mainly for the record.

The most important thing is that there are currently two problems:

 1) before48(a, b) can not decide if the difference between a and b is 2^47

 2) unsigned sequence number arithmetic 
    causes problems/headaches/curses. For instance, there are tests such as

       if( delta_seqno(a, b) > NUM_DUPACKS) 

    in the code. What happens if a and b are reordered (e.g. (5, 3) instead of (3, 5))?
    When using unsigned difference, we get the two's complement and that is a large number.
    With signed arithmetic, the former case gives a negative result and we can then decide
    whether we want to be bothered with the reordering or not.

Again, the text below is for the record - I hope to be back with a patch to implement this
before the end of the week.


Gerrit

---



		Modulo-2^48 Sequence Number Operations in DCCP
		----------------------------------------------

This text is a write-up of issues regarding sequence number comparisons and operations when
48 bits are wanted, but 64 are given. A good illustration is given in section 24.7 of Stevens,
vol 2. In particular, this text defines

	* ordering (the `before' relation which implies the `after' relation)
	* signed difference/delta of sequence numbers
	* derived relations


		Ordering n-bit numbers in modulo 2^n arithmetic
		-----------------------------------------------

The n-bits sequence numbers start at 0 and wrap around from 2^n-1 back to 0. For two n-bit sequence numbers,
a and b, we want to determine whether a is `before' b. This is a strict ordering, i.e. for all a != b exactly
one of a `before' b or b `before' must hold. When this condition is fulfilled, we obtain an implied relation:

		a `before' b      <=>      b `after' a


 (a) Assume first that a = 0

     Then a `before' b for  1 <= b <= 2^n-1

     But, since sequence numbers wrap, we also have that

                     2^(n-1)+1 ... 2^n-1 are  `before' a = 0

     To disambiguate, we define
	* 0                 is  `before' 1 ... 2^(n-1)-1
	* 2^(n-1) ... 2^n-1 are `before' 0

 (b) The general case: if a > 0 then the above just cycles around. The following table shows this.

	 a |   a `before' b           |          b `before' a
	---+--------------------------+--------------------------------------------
	 0 |   1 ... (2^(n-1) - 1)    | 2^(n-1)       ... (2^n - 1)
	 1 |   2 ...  2^(n-1)         | (2^(n-1) + 1) ... (2^n - 1) ... 0
	 2 |   3 ... (2^(n-1) + 1)    | (2^(n-1) + 2) ... (2^n - 1) ... 0 ... 1
	  ...                        ...                 .....      ...   ...   ...
         k | k+1 ... (2^(n-1) -1 + k) | (2^(n-1) + k) ... (2^n - 1 + k)
	---+--------------------------+--------------------------------------------

     (0 < k <= 2^n-1, all additions and subtractions are modulo-2^n)


 (c) Using the difference instead

     With differences we are independent of the value of k:

	* a is `before' a number b = a+1 ... (2^(n-1) - 1 + a)
          whenever (b - a) = 1 ... (2^(n-1) - 1)

	* this implies that the test "c `before' a" fails for all numbers
	  c which are such that 2^(n-1) + a  <=  c  <= 2^n - 1 + a

	* using two's complement, we get another, equivalent condition:
	  a `before' b  <=>  1            <=  b-a  <=  2^(n-1) - 1
	  		<=>  -2^(n-1) + 1 <=  a-b  <=  -1
	  This is a necessary condition, and it also shows that testing whether
	  "a-b < 0" is not sufficient for "a `before' b" since -2^(n-1) is also < 0


    		Modulo-2^48 arithmetic on 64 bit
		--------------------------------

With the above, we can instantiate a relation `before48' as follows:

		a `before48' b 	   <=>     2^47 <= a-b <= 2^48-1

In [RFC 4340, sec. 3.1] it is suggested that
 "It may make sense to store DCCP sequence numbers in the most significant 48 bits
  of 64-bit integers and set the least significant 16 bits to zero, since this
  supports a common technique that implements circular comparison A < B by testing
  whether (A - B) < 0 using conventional two's-complement arithmetic."

Unfortunately this does not work.
Signed 64-bit numbers represent the range -2^63 ... 0 ... 2^63-1. When the difference between
two left-shifted 48-bit numbers a and b is 2^63, we can not tell whether a is `before' b or
b is `before' a - the difference will always be negative due to the constraints of the data type.
This case occurs for all 48-bit numbers whose difference amounts to 2^47. Since there are 2^47
such numbers, the test based on the above test fails to produce correct results in 2^47 = 140.7375e12
cases. The suggestion from RFC 4340 can thus not be used is misleading.
We therefore develop a definition of `sequence number delta', inspired by dccp_delta_seqno().


		Computing sequence number delta
		-------------------------------

The aim is to develop a function delta_seqno(u64 a, u64 b) which essentially performs subtraction
modulo-48 of signed numbers, i.e. it shall satisfy

		(a + delta_seqno(a, b)) % 2^48  =  b

Hence delta_seqno(a, b) reduces to the subtraction b-a modulo-48, i.e.

		delta_seqno(a, b)  =  (b + 2^48 - a) % 2^48

The main difference is that we want the return result to be a _signed_ 48-bit number, i.e. the range
2^47 ... 2^48-1 is to be mapped into the range -2^47 ... -1 (two's complement in 48 bit). The following
table illustrates some cases; a, b are unsigned 48-bit numbers.

        +--------+---------+----------+---------+----------------+
	|        |         |     b + 2^48 - a   |                |
	| a      | b       | unsigned | signed  |  a `before' b  |
        +--------+---------+----------+---------+----------------+
	| 0      | 1 	   | 1	      | 1       |       X        |
	| 0      | 2^47-1  | 2^47-1   | 2^47-1  |       X        |
	| 0      | 2^47    | 2^47     | -2^47   |                |
	| 0      | 2^47+1  | 2^47+1   | -2^47-1 |                |
	| 0      | 2^48-1  | 2^48-1   | -1      |                |
	| 2^48-1 | 0       | 1        | 1       |       X        |
	| 2^47+1 | 0       | 2^47-1   | 2^47-1  |       X        |
	| 2^47   | 0       | 2^47     | -2^47   |                |
	| 2^48-3 | 5       | 8        | 8       |       X        |
	| 2^47   | 1       | 2^47+1   | -2^47-1 |                |
	| 2^47+1 | 1       | 2^47     | -2^47   |                |
	| 5      | 2^48-3  | 2^48 - 8 | -8      |                |
        +--------+---------+----------+---------+----------------+

The following is now the definition of the function delta_seqno:

#define COMPLEMENT48(x) (2^48 - x)
#define TO_SIGNED48(x)  ((x < 2^47)? : -COMPLEMENT48(x))

/* returns:
       > 0 if a `before' b
       = 0 if a = b
       < 0 which indicates that b `before' a
*/
s64 delta_seqno(u64 a, u64 b)
{
	s64 delta = (b + COMPLEMENT48(x)) % 2^48;

	return TO_SIGNED48(x);
}


		Derived comparisons for nH bit
		--------------------------------

The dccp_delta_seqno function saves a lot of work:

 (i) `before'
      a  `before' b  <=>  1 <= b-a <= 2^(n-1)-1   <=>  delta_seqno(a, b) > 0

 (ii) `after'
      a  `after' b   <=>  b `before' a            <=>  delta_seqno(b, a) > 0

 (iii) `the same as'
      a `the same as' b  <=> (a-b) = 0           <=>  delta_seqno(b, a) = 0

 (iv)  `follows'     (b is the immediate successor of a)
      b `follows' a                               <=>  delta_seqno(b, a) = 1

 (v)   `precedes'    (b is the immediate predecessor of a)
      b `precedes' a                              <=>  delta_seqno(b, a) = -1

