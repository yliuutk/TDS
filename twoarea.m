function mpc = twoarea
%2_AREA_PSSE30
%   April 12, 2016 13:35:48; Simulator Version 19; BuildDate 2016_2_6
%
%   Converted by MATPOWER 6.0 using PSSE2MPC on 08-Apr-2018
%   from '2-area_psse30.raw' using PSS/E rev 30 format.
%
%   WARNINGS:
%       Conversion explicitly using PSS/E revision 30
%       Section label mismatch, found 'VSC DC LINE', expected 'VOLTAGE SOURCE CONVERTER'
%       Section label mismatch, found 'IMPEDANCE CORRECTION TABLE', expected 'IMPEDANCE CORRECTION'
%       Skipped 1 line of zone data.
%       Skipped 1 line of owner data.
%       Section label mismatch, found 'FACTS', expected 'FACTS CONTROL DEVICE'
%       Using default voltage magnitude limits: VMIN = 0.9 p.u., VMAX = 1.1 p.u.
%
%   See CASEFORMAT for details on the MATPOWER case file format.

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	0	0	0	1	1.03	0	16.5	1	1.1	0.9;
	2	2	0	0	0	0	1	1.01	-9.2691	18.4	1	1.1	0.9;
	3	2	0	0	0	0	1	1.03	-14.3238	13.8	1	1.1	0.9;
	4	2	0	0	0	0	1	1.01	-24.4522	13.8	1	1.1	0.9;
	5	1	0	0	0	0	1	1.01416	-6.2652	230	1	1.1	0.9;
	6	1	0	0	0	0	1	0.99632	-15.9242	230	1	1.1	0.9;
	7	1	967	100	0	200	1	0.99197	-21.2407	230	1	1.1	0.9;
	8	1	0	0	0	0	1	0.98951	-25.56	230	1	1.1	0.9;
	9	1	1767	100	0	350	1	0.98695	-39.385	230	1	1.1	0.9;
	10	1	0	0	0	0	1	0.99215	-31.1354	230	1	1.1	0.9;
	11	1	0	0	0	0	1	1.01181	-20.9239	230	1	1.1	0.9;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf	mu_Pmax	mu_Pmin	mu_Qmax	mu_Qmin
mpc.gen = [
	1	684.27	135.38	300	-300	1.03	900	1	9999	-9999	0	0	0	0	0	0	0	0	0	0	0	0.0000	0.0000	0.0000	0.0000;
	2	700	123.63	300	-300	1.01	900	1	9999	-9999	0	0	0	0	0	0	0	0	0	0	0	0.0000	0.0000	0.0000	0.0000;
	3	719	153.92	300	-300	1.03	900	1	9999	-9999	0	0	0	0	0	0	0	0	0	0	0	0.0000	0.0000	0.0000	0.0000;
	4	700	149.09	300	-300	1.01	900	1	9999	-9999	0	0	0	0	0	0	0	0	0	0	0	0.0000	0.0000	0.0000	0.0000;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	5	0	0.01666	0	0	0	0	0	0	1	-360	360;
	2	6	0	0.01666	0	0	0	0	0	0	1	-360	360;
	3	11	0	0.01666	0	0	0	0	0	0	1	-360	360;
	4	10	0	0.01666	0	0	0	0	0	0	1	-360	360;
	5	6	0.0025	0.025	0.04375	0	0	0	0	0	1	-360	360;
	6	7	0.001	0.01	0.0175	0	0	0	0	0	1	-360	360;
	7	8	0.0075	0.075	0.12833	0	0	0	0	0	1	-360	360;
	7	8	0.0075	0.075	0.12833	0	0	0	0	0	1	-360	360;
	7	8	0.0075	0.075	0.12833	0	0	0	0	0	1	-360	360;
	8	9	0.018	0.18	0.1925	0	0	0	0	0	1	-360	360;
	8	9	0.018	0.18	0.1925	0	0	0	0	0	1	-360	360;
	9	10	0.001	0.01	0.0175	0	0	0	0	0	1	-360	360;
	10	11	0.0025	0.025	0.04375	0	0	0	0	0	1	-360	360;
	8	9	0.018	0.18	0.19	0	0	0	0	0	1	-360	360;
	6	7	0.002	0.02	0.017	0	0	0	0	0	1	-360	360;
	7	8	0.0075	0.075	0.12833	0	0	0	0	0	1	-360	360;
];

%% bus names
mpc.bus_name = {
	'GEN BUS1    ';
	'GEN BUS2    ';
	'GEN BUS3    ';
	'GEN BUS4    ';
	'STA B230    ';
	'STA C230    ';
	'STA 2  7    ';
	'STA A230    ';
	'STA 3  9    ';
	'STA 3 10    ';
	'STA 3 11    ';
};
