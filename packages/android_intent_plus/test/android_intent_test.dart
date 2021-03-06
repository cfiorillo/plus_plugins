// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';

void main() {
  AndroidIntent androidIntent;
  MockMethodChannel mockChannel;
  setUp(() {
    mockChannel = MockMethodChannel();
  });

  group('AndroidIntent', () {
    test('raises error if neither an action nor a component is provided', () {
      try {
        androidIntent = AndroidIntent(data: 'https://flutter.io');
        fail('should raise an AssertionError');
      } on AssertionError catch (e) {
        expect(e.message, 'action or component (or both) must be specified');
      } catch (e) {
        fail('should raise an AssertionError');
      }
    });

    group('launch', () {
      test('pass right params', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            data: Uri.encodeFull('https://flutter.io'),
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'android'),
            type: 'video/*');
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'action': 'action_view',
          'data': Uri.encodeFull('https://flutter.io'),
          'flags':
              androidIntent.convertFlags(<int>[Flag.FLAG_ACTIVITY_NEW_TASK]),
          'type': 'video/*',
        }));
      });

      test('can send Intent with an action and no component', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'action': 'action_view',
        }));
      });

      test('can send Intent with a component and no action', () async {
        androidIntent = AndroidIntent.private(
          package: 'packageName',
          componentName: 'componentName',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.launch();
        verify(mockChannel.invokeMethod<void>('launch', <String, Object>{
          'package': 'packageName',
          'componentName': 'componentName',
        }));
      });

      test('call in ios platform', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'ios'));
        await androidIntent.launch();
        verifyZeroInteractions(mockChannel);
      });
    });

    group('canResolveActivity', () {
      test('pass right params', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            data: Uri.encodeFull('https://flutter.io'),
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'android'),
            type: 'video/*');
        await androidIntent.canResolveActivity();
        verify(mockChannel
            .invokeMethod<void>('canResolveActivity', <String, Object>{
          'action': 'action_view',
          'data': Uri.encodeFull('https://flutter.io'),
          'flags':
              androidIntent.convertFlags(<int>[Flag.FLAG_ACTIVITY_NEW_TASK]),
          'type': 'video/*',
        }));
      });

      test('can send Intent with an action and no component', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.canResolveActivity();
        verify(mockChannel
            .invokeMethod<void>('canResolveActivity', <String, Object>{
          'action': 'action_view',
        }));
      });

      test('can send Intent with a component and no action', () async {
        androidIntent = AndroidIntent.private(
          package: 'packageName',
          componentName: 'componentName',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.canResolveActivity();
        verify(mockChannel
            .invokeMethod<void>('canResolveActivity', <String, Object>{
          'package': 'packageName',
          'componentName': 'componentName',
        }));
      });

      test('call in ios platform', () async {
        androidIntent = AndroidIntent.private(
            action: 'action_view',
            channel: mockChannel,
            platform: FakePlatform(operatingSystem: 'ios'));
        await androidIntent.canResolveActivity();
        verifyZeroInteractions(mockChannel);
      });
    });

    group('launchChooser', () {
      test('pass title', () async {
        androidIntent = AndroidIntent.private(
          action: 'action_view',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.launchChooser('title');
        verify(mockChannel.invokeMethod<void>('launchChooser', <String, Object>{
          'action': 'action_view',
          'chooserTitle': 'title',
        }));
      });
    });

    group('sendBroadcast', () {
      test('send a broadcast', () async {
        androidIntent = AndroidIntent.private(
          action: 'com.example.broadcast',
          channel: mockChannel,
          platform: FakePlatform(operatingSystem: 'android'),
        );
        await androidIntent.sendBroadcast();
        verify(mockChannel.invokeMethod<void>('sendBroadcast', <String, Object>{
          'action': 'com.example.broadcast',
        }));
      });
    });
  });

  group('convertFlags ', () {
    androidIntent = const AndroidIntent(
      action: 'action_view',
    );
    test('add filled flag list', () async {
      final flags = <int>[];
      flags.add(Flag.FLAG_ACTIVITY_NEW_TASK);
      flags.add(Flag.FLAG_ACTIVITY_NEW_DOCUMENT);
      expect(
        androidIntent.convertFlags(flags),
        268959744,
      );
    });
    test('add flags whose values are not power of 2', () async {
      final flags = <int>[];
      flags.add(100);
      flags.add(10);
      expect(
        () => androidIntent.convertFlags(flags),
        throwsArgumentError,
      );
    });
    test('add empty flag list', () async {
      final flags = <int>[];
      expect(
        androidIntent.convertFlags(flags),
        0,
      );
    });
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
