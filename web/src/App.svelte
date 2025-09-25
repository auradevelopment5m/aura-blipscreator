<script>
  let page = 'create';
  let showUI = false;
  let transitionAnim = false;
  let uiAnimatingOut = false;
  let activeBlips = [];
  import { onMount } from 'svelte';


  window.addEventListener('message', (event) => {
    const { action, blips, coords, type, message } = event.data;
    if (action === 'showUI') {
      showUI = true;
      uiAnimatingOut = false;
      if (blips) activeBlips = blips;
    }
    if (action === 'hideUI') {
      fadeOutUI();
    }
    if (action === 'setCoords' && coords) {
      coordsInput = `${coords.x}, ${coords.y}, ${coords.z}`;
    }
    if (action === 'showStatus') {
      statusType = type;
      statusMsg = message;
      showStatus = true;
      setTimeout(() => showStatus = false, 3000);
    }
  });

  function fadeOutUI() {
    uiAnimatingOut = true;
    setTimeout(() => {
      showUI = false;
      uiAnimatingOut = false;
    }, 300); 
  }

  function closeUI() {
    fadeOutUI();
    if (typeof fetch !== 'undefined') {
      fetch('https://aura-blipscreator/closeUI', {
        method: 'POST',
        body: JSON.stringify({})
      });
    }
  }

  window.addEventListener('keydown', (e) => {
    if (showUI && e.key === 'Escape') {
      closeUI();
    }
  });

  let label = '';
  let sprite = '';
  let color = '';
  let search = '';
  let scale = '';
  let secondaryColor = '';
  let flashing = '';
  let shortRange = '';
  let showDialog = false;
  let dialogType = '';
  let dialogBlipIdx = null;
  let showStatus = false;
  let statusType = '';
  let statusMsg = '';
  let dialogVisible = false;
  let dialogAnimatingOut = false;

  function handleSubmit() {
    openDialog('create');
  }

  function confirmCreate() {
    if (!label || !coordsInput || !sprite || !color) {
      showStatus = true;
      statusType = 'fail';
      statusMsg = 'Failed to create blip: All fields are required.';
      setTimeout(() => showStatus = false, 1800);
      showDialog = false;
      return;
    }
    if (!validateBlip(label, coordsInput, sprite, color)) {
      console.log('Validation failed');
      return;
    }
    createBlip(label, coordsInput, sprite, color, scale, secondaryColor, flashing, shortRange);
    label = coordsInput = sprite = color = scale = secondaryColor = flashing = shortRange = '';
    showStatus = true;
    statusType = 'success';
    statusMsg = 'Blip created successfully!';
    setTimeout(() => showStatus = false, 1800);
    hideDialog();
  }

  async function removeBlip(idx) {
    openDialog('remove', idx);
  }

  async function confirmRemove() {
    await fetch('https://aura-blipscreator/removeBlip', {
      method: 'POST',
      body: JSON.stringify({ idx: dialogBlipIdx })
    });
    const res = await fetch('https://aura-blipscreator/getActiveBlips', { method: 'POST' });
    activeBlips = await res.json();
    showStatus = true;
    statusType = 'success';
    statusMsg = 'Blip removed successfully!';
    setTimeout(() => showStatus = false, 1800);
    hideDialog();
  }

  async function confirmEdit() {
    const [x, y, z] = coordsInput.split(',').map(Number);
    const payload = {
      idx: dialogBlipIdx + 1,
      label,
      coords: { x, y, z },
      sprite: Number(sprite),
      color: Number(color),
      scale: scale ? Number(scale) : undefined,
      secondaryColor: secondaryColor ? Number(secondaryColor) : undefined,
      flashing: flashing === 'true' ? true : false,
      shortRange: shortRange === 'true' ? true : false
    };
    await fetch('https://aura-blipscreator/editBlip', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
    const res = await fetch('https://aura-blipscreator/getActiveBlips', { method: 'POST' });
    activeBlips = await res.json();
    page = 'list';
    showStatus = true;
    statusType = 'success';
    statusMsg = 'Blip edited successfully!';
    setTimeout(() => showStatus = false, 1800);
  }

  function closeDialog() {
    hideDialog();
  }

  function editBlip(idx) {
    const b = activeBlips[idx];
    label = b.label;
    coordsInput = `${b.coords.x}, ${b.coords.y}, ${b.coords.z}`;
    sprite = b.sprite;
    color = b.color;
    scale = b.scale || '';
    secondaryColor = b.secondaryColor || '';
    flashing = b.flashing !== undefined ? (b.flashing ? 'true' : 'false') : '';
    shortRange = b.shortRange !== undefined ? (b.shortRange ? 'true' : 'false') : '';
    dialogBlipIdx = idx;
    page = 'edit';
  }

  function goToList() {
    page = 'list';
  }

  function goToCreate() {
    page = 'create';
  }

  async function createBlip(label, coords, sprite, color, scale, secondaryColor, flashing, shortRange) {
    const [x, y, z] = coords.split(',').map(Number);
    const payload = {
      label,
      coords: { x, y, z },
      sprite: Number(sprite),
      color: Number(color),
      scale: scale ? Number(scale) : undefined,
      secondaryColor: secondaryColor ? Number(secondaryColor) : undefined,
      flashing: flashing === 'true' ? true : false,
      shortRange: shortRange === 'true' ? true : false
    };
    await fetch('https://aura-blipscreator/createBlip', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
    const res = await fetch('https://aura-blipscreator/getActiveBlips', { method: 'POST' });
    activeBlips = await res.json();
  }

  function validateBlip(label, coords, sprite, color) {
    if (
      !label.trim() ||
      !coords.trim() ||
      isNaN(Number(sprite)) ||
      isNaN(Number(color))
    ) {
      return false;
    }
    const coordsArr = coords.split(',').map(v => v.trim());
    if (
      coordsArr.length < 2 ||
      coordsArr.length > 3 ||
      coordsArr.some(v => v === '' || isNaN(Number(v)))
    ) {
      return false;
    }
    return true;
  }

  $: filteredBlips = activeBlips.filter(b =>
    b.label.toLowerCase().includes(search.toLowerCase()) ||
    b.coords.toLowerCase().includes(search.toLowerCase()) ||
    b.sprite.toLowerCase().includes(search.toLowerCase()) ||
    b.color.toLowerCase().includes(search.toLowerCase())
  );

  function openDialog(type, idx = null) {
    dialogType = type;
    dialogBlipIdx = idx;
    dialogVisible = true;
    dialogAnimatingOut = false;
  }

  function hideDialog() {
    dialogAnimatingOut = true;
    setTimeout(() => {
      dialogVisible = false;
      dialogAnimatingOut = false;
    }, 280);
  }

  let coordsInput = '';

  function requestCoords() {
    fetch('https://aura-blipscreator/getPlayerCoords', {
      method: 'POST',
      body: JSON.stringify({})
    });
  }

  window.addEventListener('message', (event) => {
    const { action, coords } = event.data;
    if (action === 'setCoords' && coords) {
      coordsInput = `${coords.x}, ${coords.y}, ${coords.z}`;
    }
  });

  let flashingDropdownOpen = false;
  let shortRangeDropdownOpen = false;

  function copyReference(url) {
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(url).then(() => {
        showStatus = false;
        setTimeout(() => {
          statusType = 'success';
          statusMsg = 'Link copied! Paste it in your browser.';
          showStatus = true;
          setTimeout(() => showStatus = false, 1800);
        }, 10);
      }).catch(() => {
        fallbackCopyTextToClipboard(url);
      });
    } else {
      fallbackCopyTextToClipboard(url);
    }
  }

  function fallbackCopyTextToClipboard(text) {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.setAttribute('readonly', '');
    textarea.style.position = 'absolute';
    textarea.style.left = '-9999px';
    document.body.appendChild(textarea);
    textarea.select();
    try {
      document.execCommand('copy');
      showStatus = false;
      setTimeout(() => {
        statusType = 'success';
        statusMsg = 'Link copied! Paste it in your browser.';
        showStatus = true;
        setTimeout(() => showStatus = false, 1800);
      }, 10);
    } catch (err) {
      showStatus = false;
      setTimeout(() => {
        statusType = 'fail';
        statusMsg = 'Failed to copy link. Please copy manually.';
        showStatus = true;
        setTimeout(() => showStatus = false, 1800);
      }, 10);
    }
    document.body.removeChild(textarea);
  }

  onMount(() => {
    function handleClickOutside(e) {
      if (!e.target.closest('.custom-dropdown')) {
        flashingDropdownOpen = false;
        shortRangeDropdownOpen = false;
      }
    }
    window.addEventListener('mousedown', handleClickOutside);
    return () => window.removeEventListener('mousedown', handleClickOutside);
  });
</script>

<style>
  .tablet-ui-fade-out {
    animation: tabletFadeOut 0.3s forwards;
  }

  @keyframes tabletFadeOut {
    from { opacity: 1; }
    to { opacity: 0; }
  }

  .tablet-tooltip {
    pointer-events: auto !important;
  }
</style>

{#if showStatus}
  <div class="tablet-status" style="background:{statusType === 'fail' ? '#d9534f' : ''};color:#fff;">
    {statusMsg}
  </div>
{/if}

{#if showUI}
  <div class:tablet-ui-fade-out={uiAnimatingOut}>
    {#if page === 'create'}
      <form class="tablet-form" on:submit|preventDefault={handleSubmit}>
        <button type="button" class="tablet-exit-btn" on:click={closeUI} tabindex="0">
          ×
          <span class="tablet-tooltip">Close</span>
        </button>
        <div class="tablet-form-header">Blip Creator</div>
        <div class="tablet-form-desc">Create a new map blip with custom label, coordinates, sprite, and color.</div>
        <div class="tablet-form-header-line"></div>
        <div class="tablet-form-row">
          <div class="tablet-form-group" style="flex:1;">
            <label for="label">Label</label>
            <input id="label" type="text" bind:value={label} placeholder="Label" class="tablet-input" required />
            <span class="tablet-tooltip">Blip name</span>
          </div>
          <div class="tablet-form-group" style="position:relative;">
            <div style="display:flex;align-items:center;gap:8px;">
              <label for="coords">Coords</label>
              <button type="button" class="tablet-btn" style="padding:6px 12px;font-size:0.95rem;width:auto;" on:click={requestCoords}>
                Get Coords
              </button>
            </div>
            <input id="coords" type="text" bind:value={coordsInput} placeholder="Coords (e.g. 123.45, 678.90, 21.0)" class="tablet-input" required />
            <span class="tablet-tooltip">Blip coordinates</span>
          </div>
        </div>
        <div class="tablet-form-row">
          <div class="tablet-form-group">
            <div style="display:flex;align-items:center;gap:8px;">
              <label for="sprite">Sprite</label>
              <button
                type="button"
                class="tablet-btn"
                tabindex="0"
                style="padding:6px 12px;font-size:0.95rem;width:auto;"
                on:click={() => copyReference('https://docs.fivem.net/docs/game-references/blips/#blips')}
                on:keydown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); copyReference('https://docs.fivem.net/docs/game-references/blips/#blips'); } }}
              >
                Copy Reference Link
              </button>
            </div>
            <input id="sprite" type="text" bind:value={sprite} placeholder="Sprite ID" class="tablet-input" required />
            <span class="tablet-tooltip">Blip sprite.</span>
          </div>
          <div class="tablet-form-group">
            <div style="display:flex;align-items:center;gap:8px;">
              <label for="color">Color</label>
              <button
                type="button"
                class="tablet-btn"
                tabindex="0"
                style="padding:6px 12px;font-size:0.95rem;width:auto;"
                on:click={() => copyReference('https://docs.fivem.net/docs/game-references/blips/#blip-colors')}
                on:keydown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); copyReference('https://docs.fivem.net/docs/game-references/blips/#blip-colors'); } }}
              >
                Copy Reference Link
              </button>
            </div>
            <input id="color" type="text" bind:value={color} placeholder="Color ID" class="tablet-input" required />
            <span class="tablet-tooltip">Blip color.</span>
          </div>
        </div>
        <div class="tablet-form-row">
          <div class="tablet-form-group">
            <label for="scale">Scale</label>
            <input id="scale" type="number" min="0.1" max="1.0" step="0.01" bind:value={scale} placeholder="Scale (max 1.0)" class="tablet-input" />
            <span class="tablet-tooltip">Blip scale (default: 1.0)</span>
          </div>
          <div class="tablet-form-group">
            <label for="secondaryColor">Secondary Color</label>
            <input id="secondaryColor" type="text" bind:value={secondaryColor} placeholder="Secondary Color ID (optional)" class="tablet-input" />
            <span class="tablet-tooltip">Blip secondary color ID (optional)</span>
          </div>
        </div>
        <div class="tablet-form-row">
          <div class="tablet-form-group">
            <label for="flashing">Flashing</label>
            <div class="custom-dropdown" tabindex="0" on:mousedown|stopPropagation on:click|stopPropagation>
              <div class="custom-dropdown-selected" on:click={() => flashingDropdownOpen = !flashingDropdownOpen}>
                {flashing === '' ? 'Default' : flashing === 'true' ? 'True' : 'False'}
                <span class="dropdown-arrow"></span>
              </div>
              {#if flashingDropdownOpen}
                <div class="custom-dropdown-list" tabindex="0" on:mousedown|stopPropagation on:click|stopPropagation>
                  <div class="custom-dropdown-item" on:click={() => { flashing = ''; flashingDropdownOpen = false; }}>Default</div>
                  <div class="custom-dropdown-item" on:click={() => { flashing = 'true'; flashingDropdownOpen = false; }}>True</div>
                  <div class="custom-dropdown-item" on:click={() => { flashing = 'false'; flashingDropdownOpen = false; }}>False</div>
                </div>
              {/if}
            </div>
            <span class="tablet-tooltip">Make blip flash (optional)</span>
          </div>
          <div class="tablet-form-group">
            <label for="shortRange">Short Range</label>
            <div class="custom-dropdown" tabindex="0" on:mousedown|stopPropagation on:click|stopPropagation>
              <div class="custom-dropdown-selected" on:click={() => shortRangeDropdownOpen = !shortRangeDropdownOpen}>
                {shortRange === '' ? 'Default' : shortRange === 'true' ? 'True' : 'False'}
                <span class="dropdown-arrow"></span>
              </div>
              {#if shortRangeDropdownOpen}
                <div class="custom-dropdown-list" tabindex="0" on:mousedown|stopPropagation on:click|stopPropagation>
                  <div class="custom-dropdown-item" on:click={() => { shortRange = ''; shortRangeDropdownOpen = false; }}>Default</div>
                  <div class="custom-dropdown-item" on:click={() => { shortRange = 'true'; shortRangeDropdownOpen = false; }}>True</div>
                  <div class="custom-dropdown-item" on:click={() => { shortRange = 'false'; shortRangeDropdownOpen = false; }}>False</div>
                </div>
              {/if}
            </div>
            <span class="tablet-tooltip">Only show when nearby (optional)</span>
          </div>
        </div>
        <button class="tablet-btn" type="submit" data-tooltip-above>
          Create Blip
          <span class="tablet-tooltip">Create a new blip</span>
        </button>
        <button class="tablet-btn" style="margin-top:8px;" type="button" on:click={goToList}>
          View Active Blips
          <span class="tablet-tooltip">Show all blips</span>
        </button>
      </form>
    {:else if page === 'list'}
      <div class="tablet-list {transitionAnim ? 'exit' : ''}">
        <button type="button" class="tablet-exit-btn" on:click={closeUI} tabindex="0">
          ×
          <span class="tablet-tooltip">Close</span>
        </button>
        <div class="tablet-list-header">Active Blips</div>
        <div class="tablet-list-desc">Edit or remove blips from the list below.</div>
        <div class="tablet-list-header-line"></div>
        <div class="tablet-search">
          <input type="text" bind:value={search} placeholder="Search blips..." />
        </div>
        <div class="tablet-cards">
          {#each filteredBlips as blip, idx}
            <div class="tablet-card">
              <div class="tablet-card-header">{blip.label}</div>
              <div class="tablet-card-row">
                <span class="tablet-card-tag">Sprite: {blip.sprite}</span>
                <span class="tablet-card-tag">Color: {blip.color}</span>
              </div>
              {#if blip.desc}
                <div class="tablet-card-desc">{blip.desc}</div>
              {/if}
              <div style="display:flex;gap:10px;margin-top:10px;">
                <button class="tablet-btn" data-tooltip-above style="padding:8px 16px;font-size:0.95rem;" on:click={() => editBlip(idx)}>
                  Edit
                  <span class="tablet-tooltip">Edit this blip</span>
                </button>
                <button class="tablet-btn" data-tooltip-above style="padding:8px 16px;font-size:0.95rem;background:#d9534f;" on:click={() => removeBlip(idx + 1)}>
                  Remove
                  <span class="tablet-tooltip">Remove this blip</span>
                </button>
              </div>
            </div>
          {/each}
        </div>
        <button class="tablet-btn" style="margin-top:8px;" type="button" on:click={goToCreate}>
          Back to Creator
          <span class="tablet-tooltip">Go back to blip creator</span>
        </button>
      </div>
    {:else if page === 'edit'}
      <form class="tablet-form" on:submit|preventDefault={confirmEdit}>
        <button type="button" class="tablet-exit-btn" on:click={closeUI} tabindex="0">
          ×
          <span class="tablet-tooltip">Close</span>
        </button>
        <div class="tablet-form-header">Edit Blip</div>
        <div class="tablet-form-desc">Modify the blip details below.</div>
        <div class="tablet-form-header-line"></div>
        <div class="tablet-form-row">
          <div class="tablet-form-group">
            <label for="label">Label</label>
            <input id="label" type="text" bind:value={label} placeholder="Label" class="tablet-input" required />
            <span class="tablet-tooltip">Blip name</span>
          </div>
          <div class="tablet-form-group" style="position:relative;">
            <div style="display:flex;align-items:center;gap:8px;">
              <label for="coords">Coords</label>
              <button type="button" class="tablet-btn" style="padding:6px 12px;font-size:0.95rem;width:auto;" on:click={requestCoords}>
                Get Coords
              </button>
            </div>
            <input id="coords" type="text" bind:value={coordsInput} placeholder="Coords (e.g. 123.45, 678.90, 21.0)" class="tablet-input" required />
            <span class="tablet-tooltip">Blip coordinates</span>
          </div>
        </div>
        <div class="tablet-form-row">
          <div class="tablet-form-group">
            <label for="sprite">Sprite</label>
            <input id="sprite" type="text" bind:value={sprite} placeholder="Sprite ID" class="tablet-input" required />
            <span class="tablet-tooltip">Blip sprite.</span>
          </div>
          <div class="tablet-form-group">
            <div style="display:flex;align-items:center;gap:8px;">
              <label for="color">Color</label>
              <button
                type="button"
                class="tablet-btn"
                tabindex="0"
                style="padding:6px 12px;font-size:0.95rem;width:auto;"
                on:click={() => copyReference('https://docs.fivem.net/docs/game-references/blips/#blip-colors')}
                on:keydown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); copyReference('https://docs.fivem.net/docs/game-references/blips/#blip-colors'); } }}
              >
                Copy Reference Link
              </button>
            </div>
            <input id="color" type="text" bind:value={color} placeholder="Color ID" class="tablet-input" required />
            <span class="tablet-tooltip">Blip color.</span>
          </div>
        </div>
        <div class="tablet-form-row">
          <div class="tablet-form-group">
            <label for="scale">Scale</label>
            <input id="scale" type="number" min="0.1" max="1.0" step="0.01" bind:value={scale} placeholder="Scale (max 1.0)" class="tablet-input" />
            <span class="tablet-tooltip">Blip scale (default: 1.0)</span>
          </div>
          <div class="tablet-form-group">
            <label for="secondaryColor">Secondary Color</label>
            <input id="secondaryColor" type="text" bind:value={secondaryColor} placeholder="Secondary Color ID (optional)" class="tablet-input" />
            <span class="tablet-tooltip">Blip secondary color ID (optional)</span>
          </div>
        </div>
        <div class="tablet-form-row">
          <div class="tablet-form-group">
            <label for="flashing">Flashing</label>
            <div class="custom-dropdown" tabindex="0" on:mousedown|stopPropagation on:click|stopPropagation>
              <div class="custom-dropdown-selected" on:click={() => flashingDropdownOpen = !flashingDropdownOpen}>
                {flashing === '' ? 'Default' : flashing === 'true' ? 'True' : 'False'}
                <span class="dropdown-arrow"></span>
              </div>
              {#if flashingDropdownOpen}
                <div class="custom-dropdown-list" tabindex="0" on:mousedown|stopPropagation on:click|stopPropagation>
                  <div class="custom-dropdown-item" on:click={() => { flashing = ''; flashingDropdownOpen = false; }}>Default</div>
                  <div class="custom-dropdown-item" on:click={() => { flashing = 'true'; flashingDropdownOpen = false; }}>True</div>
                  <div class="custom-dropdown-item" on:click={() => { flashing = 'false'; flashingDropdownOpen = false; }}>False</div>
                </div>
              {/if}
            </div>
            <span class="tablet-tooltip">Make blip flash (optional)</span>
          </div>
          <div class="tablet-form-group">
            <label for="shortRange">Short Range</label>
            <div class="custom-dropdown" tabindex="0" on:mousedown|stopPropagation on:click|stopPropagation>
              <div class="custom-dropdown-selected" on:click={() => shortRangeDropdownOpen = !shortRangeDropdownOpen}>
                {shortRange === '' ? 'Default' : shortRange === 'true' ? 'True' : 'False'}
                <span class="dropdown-arrow"></span>
              </div>
              {#if shortRangeDropdownOpen}
                <div class="custom-dropdown-list" tabindex="0" on:mousedown|stopPropagation on:click|stopPropagation>
                  <div class="custom-dropdown-item" on:click={() => { shortRange = ''; shortRangeDropdownOpen = false; }}>Default</div>
                  <div class="custom-dropdown-item" on:click={() => { shortRange = 'true'; shortRangeDropdownOpen = false; }}>True</div>
                  <div class="custom-dropdown-item" on:click={() => { shortRange = 'false'; shortRangeDropdownOpen = false; }}>False</div>
                </div>
              {/if}
            </div>
            <span class="tablet-tooltip">Only show when nearby (optional)</span>
          </div>
        </div>
        <button class="tablet-btn" type="submit" data-tooltip-above>
          Save Changes
          <span class="tablet-tooltip">Save blip changes</span>
        </button>
        <button class="tablet-btn" style="margin-top:8px;" type="button" on:click={goToList}>
          Cancel
          <span class="tablet-tooltip">Cancel editing</span>
        </button>
      </form>
    {/if}

    {#if dialogVisible}
      <div class="tablet-dialog-bg">
        <div class="tablet-dialog {dialogAnimatingOut ? 'tablet-dialog-animate-out' : 'tablet-dialog-animate-in'}">
          {#if dialogType === 'create'}
            <div class="tablet-dialog-title">Confirm Create</div>
            <div class="tablet-dialog-desc">Are you sure you want to create this blip?</div>
            <div class="tablet-dialog-actions">
              <button class="tablet-dialog-btn" on:click={confirmCreate}>Yes</button>
              <button class="tablet-dialog-btn red" on:click={closeDialog}>Cancel</button>
            </div>
          {:else if dialogType === 'remove'}
            <div class="tablet-dialog-title">Confirm Remove</div>
            <div class="tablet-dialog-desc">Are you sure you want to remove this blip?</div>
            <div class="tablet-dialog-actions">
              <button class="tablet-dialog-btn red" on:click={confirmRemove}>Remove</button>
              <button class="tablet-dialog-btn" on:click={closeDialog}>Cancel</button>
            </div>
          {/if}
        </div>
      </div>
    {/if}

  </div>
{/if}

