/* todo:
	make dot operator into legit binary operator
	implement arrow operator (or maybe use dot for same purpose?)
*/

struct Test {
	int a;
	int b;
};

void init() {
	Test t;
	t.a = 1;
	t.b = 2;

	Test* tp = 0;

	*tp = t;

	int ia = tp -> a;
	int ib = tp -> b;
}
