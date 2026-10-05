package io.github.ecrevissemiroir.yominow

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.ichi2.anki.api.AddContentApi

class MainActivity : FlutterActivity() {
	private data class PendingCard(
		val word: String,
		val back: String,
		val result: MethodChannel.Result,
	)

	private var pendingCard: PendingCard? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ANKI_CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"addNote" -> addNote(call, result)
					"isDuplicate" -> isDuplicate(call, result)
					else -> result.notImplemented()
				}
			}
	}

	private fun isDuplicate(call: MethodCall, result: MethodChannel.Result) {
		val word = call.argument<String>("word")?.trim().orEmpty()
		if (word.isEmpty() || AddContentApi.getAnkiDroidPackageName(this) == null) {
			result.success(false)
			return
		}
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
			checkSelfPermission(ANKI_PERMISSION) != PackageManager.PERMISSION_GRANTED
		) {
			result.success(false)
			return
		}

		try {
			val api = AddContentApi(this)
			val preferences = getSharedPreferences(ANKI_PREFERENCES, MODE_PRIVATE)
			val modelIds = existingModelIds(api, preferences)
			if (modelIds.isEmpty()) {
				result.success(false)
				return
			}
			result.success(
				modelIds.any { !api.findDuplicateNotes(it, word).isNullOrEmpty() },
			)
		} catch (_: Exception) {
			result.success(false)
		}
	}

	private fun addNote(call: MethodCall, result: MethodChannel.Result) {
		val word = call.argument<String>("word")?.trim().orEmpty()
		if (word.isEmpty()) {
			result.error("INVALID_CARD", "A word is required.", null)
			return
		}
		val back = call.argument<String>("back").orEmpty()

		try {
			packageManager.getApplicationInfo(ANKI_PACKAGE, 0)
		} catch (_: PackageManager.NameNotFoundException) {
			result.error(
				"ANKIDROID_NOT_INSTALLED",
				"Install AnkiDroid to add flashcards.",
				null,
			)
			return
		}
		if (AddContentApi.getAnkiDroidPackageName(this) == null) {
			shareToAnkiDroid(word, back, result)
			return
		}

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
			checkSelfPermission(ANKI_PERMISSION) != PackageManager.PERMISSION_GRANTED
		) {
			if (pendingCard != null) {
				result.error(
					"REQUEST_IN_PROGRESS",
					"An AnkiDroid request is already open.",
					null,
				)
				return
			}
			pendingCard = PendingCard(word, back, result)
			requestPermissions(arrayOf(ANKI_PERMISSION), ANKI_PERMISSION_REQUEST)
			return
		}

		addDirectlyOrShare(word, back, result)
	}

	@Deprecated("Required for the AnkiDroid API permission callback")
	override fun onRequestPermissionsResult(
		requestCode: Int,
		permissions: Array<out String>,
		grantResults: IntArray,
	) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)
		if (requestCode != ANKI_PERMISSION_REQUEST) return

		val pending = pendingCard ?: return
		pendingCard = null
		if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
			addDirectlyOrShare(pending.word, pending.back, pending.result)
		} else {
			shareToAnkiDroid(pending.word, pending.back, pending.result)
		}
	}

	private fun addDirectlyOrShare(
		word: String,
		back: String,
		result: MethodChannel.Result,
	) {
		try {
			val api = AddContentApi(this)
			val preferences = getSharedPreferences(ANKI_PREFERENCES, MODE_PRIVATE)
			val deckId = resolveDeckId(api, preferences)
				?: throw IllegalStateException("Could not create the YomiNow deck.")
			val modelId = resolveModelId(api, preferences, createIfMissing = true)
				?: throw IllegalStateException("Could not create the YomiNow card type.")
			val modelIds = (existingModelIds(api, preferences) + modelId).distinct()
			if (modelIds.any { !api.findDuplicateNotes(it, word).isNullOrEmpty() }) {
				result.success("duplicate")
				return
			}
			val noteId = api.addNote(modelId, deckId, arrayOf(word, back), null)
			if (noteId <= 0L) {
				throw IllegalStateException("AnkiDroid could not add this note.")
			}
			result.success("added")
		} catch (_: SecurityException) {
			shareToAnkiDroid(word, back, result)
		} catch (_: Exception) {
			shareToAnkiDroid(word, back, result)
		}
	}

	private fun resolveDeckId(
		api: AddContentApi,
		preferences: android.content.SharedPreferences,
	): Long? {
		val decks = api.deckList.orEmpty()
		val savedId = preferences.getLong(DECK_ID_KEY, 0L)
		val deckId = decks.entries.firstOrNull {
			it.value.equals(DECK_NAME, ignoreCase = true)
		}?.key ?: savedId.takeIf { decks.containsKey(it) }
			?: api.addNewDeck(DECK_NAME)
		if (deckId != null) preferences.edit().putLong(DECK_ID_KEY, deckId).apply()
		return deckId
	}

	private fun resolveModelId(
		api: AddContentApi,
		preferences: android.content.SharedPreferences,
		createIfMissing: Boolean,
	): Long? {
		val modelId = existingModelIds(api, preferences).firstOrNull()
			?: if (createIfMissing) api.addNewBasicModel(MODEL_NAME) else null
		if (modelId != null) preferences.edit().putLong(MODEL_ID_KEY, modelId).apply()
		return modelId
	}

	private fun existingModelIds(
		api: AddContentApi,
		preferences: android.content.SharedPreferences,
	): List<Long> {
		val models = api.modelList.orEmpty()
		fun isBasicModel(id: Long) = api.getFieldList(id)?.size == 2

		val namedModel = models.entries.firstOrNull {
			it.value.equals(MODEL_NAME, ignoreCase = true) && isBasicModel(it.key)
		}?.key
		val savedId = preferences.getLong(MODEL_ID_KEY, 0L)
		val savedModel = savedId.takeIf { models.containsKey(it) && isBasicModel(it) }
		val previousModel = models.entries.firstOrNull {
			it.value.equals(LEGACY_MODEL_NAME, ignoreCase = true) && isBasicModel(it.key)
		}?.key
		return listOfNotNull(namedModel, savedModel, previousModel).distinct()
	}

	private fun shareToAnkiDroid(
		word: String,
		back: String,
		result: MethodChannel.Result,
	) {
		try {
			val intent = Intent(Intent.ACTION_SEND).apply {
				type = "text/plain"
				setPackage(ANKI_PACKAGE)
				putExtra(Intent.EXTRA_SUBJECT, word)
				putExtra(Intent.EXTRA_TEXT, back)
			}
			if (intent.resolveActivity(packageManager) == null) {
				result.error(
					"ANKIDROID_API_UNAVAILABLE",
					"Enable API Integration in AnkiDroid under Settings > Advanced, then try again.",
					null,
				)
				return
			}
			startActivity(intent)
			result.success("shared")
		} catch (error: Exception) {
			result.error("ANKIDROID_SHARE_FAILED", error.message, null)
		}
	}

	private companion object {
		const val ANKI_CHANNEL = "io.github.ecrevissemiroir.yominow/anki"
		const val ANKI_PERMISSION = "com.ichi2.anki.permission.READ_WRITE_DATABASE"
		const val ANKI_PERMISSION_REQUEST = 7401
		const val ANKI_PACKAGE = "com.ichi2.anki"
		const val ANKI_PREFERENCES = "ankidroid_api"
		const val DECK_ID_KEY = "deck_id"
		const val MODEL_ID_KEY = "model_id"
		const val DECK_NAME = "YomiNow"
		const val MODEL_NAME = "YomiNow"
		const val LEGACY_MODEL_NAME = "YomiNow Japanese Vocabulary"
	}
}
