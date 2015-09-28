import 'package:quiver/testing/async.dart';
import 'package:sky/src/fn3.dart';
import 'package:test/test.dart';

import '../fn3/widget_tester.dart';

const Size pageSize = const Size(800.0, 600.0);
const List<int> pages = const <int>[0, 1, 2, 3, 4, 5];
int currentPage = null;
bool itemsWrap = false;

Widget buildPage(BuildContext context, int page) {
  return new Container(
    key: new ValueKey<int>(page),
    width: pageSize.width,
    height: pageSize.height,
    child: new Text(page.toString())
  );
}

Widget buildFrame() {
  // The test framework forces the frame (and so the PageableList)
  // to be 800x600. The pageSize constant reflects this.
  return new PageableList<int>(
    items: pages,
    itemBuilder: buildPage,
    itemsWrap: itemsWrap,
    itemExtent: pageSize.width,
    scrollDirection: ScrollDirection.horizontal,
    onPageChanged: (int page) { currentPage = page; }
  );
}

void page(WidgetTester tester, Offset offset) {
  String itemText = currentPage != null ? currentPage.toString() : '0';
  new FakeAsync().run((async) {
    tester.scroll(tester.findText(itemText), offset);
    // One frame to start the animation, a second to complete it.
    tester.pumpFrameWithoutChange();
    tester.pumpFrameWithoutChange(1000.0);
    async.elapse(new Duration(seconds: 1));
  });
}

void pageLeft(WidgetTester tester) {
  page(tester, new Offset(-pageSize.width, 0.0));
}

void pageRight(WidgetTester tester) {
  page(tester, new Offset(pageSize.width, 0.0));
}

void main() {
  // PageableList with itemsWrap: false

  test('Scroll left from page 0 to page 1', () {
    WidgetTester tester = new WidgetTester();
    currentPage = null;
    itemsWrap = false;
    tester.pumpFrame(buildFrame());
    expect(currentPage, isNull);
    pageLeft(tester);
    expect(currentPage, equals(1));
  });

  test('Scroll right from page 1 to page 0', () {
    WidgetTester tester = new WidgetTester();
    itemsWrap = false;
    tester.pumpFrame(buildFrame());
    expect(currentPage, equals(1));
    pageRight(tester);
    expect(currentPage, equals(0));
  });

  test('Scroll right from page 0 does nothing (underscroll)', () {
    WidgetTester tester = new WidgetTester();
    itemsWrap = false;
    tester.pumpFrame(buildFrame());
    expect(currentPage, equals(0));
    pageRight(tester);
    expect(currentPage, equals(0));
  });

  // PageableList with itemsWrap: true

  test('Scroll left page 0 to page 1, itemsWrap: true', () {
    WidgetTester tester = new WidgetTester();
    tester.reset();
    currentPage = null;
    itemsWrap = true;
    tester.pumpFrame(buildFrame());
    expect(currentPage, isNull);
    pageLeft(tester);
    expect(currentPage, equals(1));
  });

  test('Scroll right from page 1 to page 0, itemsWrap: true', () {
    WidgetTester tester = new WidgetTester();
    tester.pumpFrame(buildFrame());
    expect(currentPage, equals(1));
    pageRight(tester);
    expect(currentPage, equals(0));
  });

  test('Scroll right from page 0 to page 5, itemsWrap: true (underscroll)', () {
    WidgetTester tester = new WidgetTester();
    tester.pumpFrame(buildFrame());
    expect(currentPage, equals(0));
    pageRight(tester);
    expect(currentPage, equals(5));
  });
}
